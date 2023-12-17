from markdown.preprocessors import Preprocessor
from markdown.inlinepatterns import InlineProcessor
from markdown import Extension
import class_url_provider
import re
from xml.etree.ElementTree import Element, TreeBuilder

class ClassMemberExtension(Extension):
    def extendMarkdown(self, md):
        md.registerExtension(self)
        self.md = md
        md.preprocessors.register(ClassMemberPreprocessor(md, class_url_provider.ClassUrlProvider()), "class_member_preprocessor", 0)
        md.inlinePatterns.register(ClassMemberResolvingInlineProcessor(r":(?P<command>[a-z:]+):(`(?P<parameter>[a-zA-Z0-9_#.]+)`)?", md, class_url_provider.ClassUrlProvider()), "class_member_resolver", 1000)

    def reset(self):
        self.md.class_members = {}

class ClassMemberResolvingInlineProcessor(InlineProcessor):
    def __init__(self, pattern, md, class_url_provider):
        super().__init__(pattern, md)
        self.class_url_provider = class_url_provider

    def handleMatch(self, m, data):
        command = m.group("command")
        parameter = m.group("parameter")
        return self.handleCommand(command, parameter), m.start(0), m.end(0)
    
    def handleCommand(self, command, parameter) -> Element:
        match command:
            case "constant":
                return self.build_constant(parameter)
            case "constant:short":
                return self.build_constant(parameter, short = True)
            case "constants":
                return self.build_constants_table()
            case "enum":
                return self.build_enum(parameter)
            case "enum:anchor":
                return self.build_enum(parameter, outer_attributes = {"id": parameter})
            case "enum_entry":
                return self.build_enum_entry(parameter)
            case "property":
                return self.build_property(parameter)
            case "property:anchor":
                return self.build_property(parameter, outer_attributes = {"id": parameter})
            case "property:short":
                return self.build_property(parameter, short = True)
            case "properties":
                return self.build_properties_table()
            case "method":
                return self.build_method(parameter)
            case "method:anchor":
                return self.build_method(parameter, outer_attributes = {"id": parameter})
            case "method:short":
                return self.build_method(parameter, short = True)
            case "methods":
                return self.build_methods_table()
            case "signal":
                return self.build_signal(parameter)
            case "signal:anchor":
                return self.build_signal(parameter, outer_attributes = {"id": parameter})
            case "param":
                return self.build_parameter(parameter)
            case "link":
                return self.build_link(parameter)
            case _:
                return None
    
    def build_link(self, target):
        builder: TreeBuilder = TreeBuilder()
        parts = target.split("#")
        if target.startswith("#"):
            builder.start("a", {"href": target})
            builder.data(target[1:])
        elif len(parts) == 1:
            parts = target.split(".")
            if len(parts) == 1:
                builder.start("a", {"href": self.fix_url(self.class_url_provider.get_href(target))})
                builder.data(target)
            else:
                builder.start("a", {"href": self.fix_url(self.class_url_provider.get_href(parts[0])) + "#" + parts[1]})
                builder.data(parts[1])
        else:
            builder.start("a", {"href": self.fix_url(self.class_url_provider.get_href(parts[0])) + "#" + parts[1]})
            builder.data(target)
        builder.end("a")
        return builder.close()

    def build_property(self, property: str, outer_attributes: dict = {}, short = False) -> Element:
        builder: TreeBuilder = TreeBuilder()
        builder.start("span", outer_attributes)
        self.build_param(builder, self.md.class_members["properties"][property], short = short)
        builder.end("span")
        return builder.close()
    
    def build_properties_table(self, sort: bool = True) -> Element:
        builder: TreeBuilder = TreeBuilder()
        builder.start("table", {})
        properties = self.md.class_members["properties"]
        for key in (sorted(properties) if sort else properties):
            sig = properties[key]
            builder.start("tr", {})
            builder.start("td", {})
            if "type" in sig:
                self.build_node(builder, sig["type"])
            else:
                self.build_node(builder, {
                    "text": "???",
                    "class": "Variant"
                })
            builder.end("td")
            builder.start("td", {})
            self.build_param(builder, sig, type = False)
            builder.end("td")
            builder.end("tr")
        builder.end("table")
        return builder.close()
    
    def build_constant(self, constant: str, short = False) -> Element:
        builder: TreeBuilder = TreeBuilder()
        builder.start("span", {})
        self.build_param(builder, self.md.class_members["constants"][constant], short = short)
        builder.end("span")
        return builder.close()

    def build_constants_table(self, sort: bool = True) -> Element:
        builder: TreeBuilder = TreeBuilder()
        builder.start("table", {})
        constants = self.md.class_members["constants"]
        for key in (sorted(constants) if sort else constants):
            sig = constants[key]
            builder.start("tr", {})
            builder.start("td", {})
            if "type" in sig:
                self.build_node(builder, sig["type"])
            else:
                self.build_node(builder, {
                    "text": "???",
                    "class": "Variant"
                })
            builder.end("td")
            builder.start("td", {})
            self.build_node(builder, sig["name"])
            builder.end("td")
            builder.start("td", {})
            self.build_node(builder, sig["default"])
            builder.end("td")
            builder.end("tr")
        builder.end("table")
        return builder.close()
    
    def build_enum(self, enum_name: str, outer_attributes: dict = {}) -> Element:
        builder: TreeBuilder = TreeBuilder()
        builder.start("span", outer_attributes)
        builder.data("enum ")
        self.build_node(builder, self.md.class_members["enums"][enum_name]["name"])
        builder.data(":")
        builder.start("ul", {})
        for index, entry in enumerate(self.md.class_members["enums"][enum_name]["entries"]):
            builder.start("li", {})
            self.build_node(builder, entry)
            builder.data(" = ")
            self.build_node(builder, {
                "text": str(index),
                "class": "default"
            })
            builder.end("li")
        builder.end("ul")
        builder.end("span")
        return builder.close()

    def build_enum_entry(self, enum_entry: str) -> Element:
            enum_name, entry_name = enum_entry.split(".")
            builder: TreeBuilder = TreeBuilder()
            builder.start("span", {})
            self.build_node(builder, self.md.class_members["enums"][enum_name]["entry_map"][entry_name])
            builder.end("span")
            return builder.close()

    def build_method(self, method: str, outer_attributes: dict = {}, short = False) -> Element:
        builder: TreeBuilder = TreeBuilder()
        builder.start("span", outer_attributes)
        sig = self.md.class_members["methods"][method]
        if not short and "static" in sig:
            self.build_node(builder, sig["static"])
            builder.data(" ")
        if not short and "return_type" in sig:
            self.build_node(builder, sig["return_type"])
            builder.data(" ")
        self.build_method_no_return_type(builder, sig)
        builder.end("span")
        return builder.close()

    def build_method_no_return_type(self, builder: TreeBuilder, sig: dict):
        self.build_node(builder, sig["method"])
        builder.data(" ")
        params = sig["params"]
        if len(params) == 0:
            self.brackets(builder)
            return builder.close()
        self.lbracket(builder)
        builder.data(" ")
        len_minus_one = len(params) - 1
        for i in range(len(params)):
            param = params[i]
            self.build_param(builder, param)
            if i < len_minus_one:
                builder.data(", ")
        builder.data(" ")
        self.rbracket(builder)

    def build_methods_table(self, sort: bool = True) -> Element:
        builder: TreeBuilder = TreeBuilder()
        builder.start("table", {})
        methods = self.md.class_members["methods"]
        for key in (sorted(methods) if sort else methods):
            sig = methods[key]
            builder.start("tr", {})
            builder.start("td", {})
            if "return_type" in sig:
                self.build_node(builder, sig["return_type"])
            else:
                self.build_node(builder, {
                    "text": "???",
                    "class": "void"
                })
            builder.end("td")
            builder.start("td", {})
            if "static" in sig:
                self.build_node(builder, sig["static"])
                builder.data(" ")
            self.build_method_no_return_type(builder, sig)
            builder.end("td")
            builder.end("tr")
        builder.end("table")
        return builder.close()

    
    def build_signal(self, signal: str, outer_attributes: dict = {}) -> Element:
        builder: TreeBuilder = TreeBuilder()
        builder.start("span", outer_attributes)
        sig = self.md.class_members["signals"][signal]
        self.build_node(builder, sig["signal"])
        builder.data(" ")
        params = sig["params"]
        if len(params) == 0:
            self.brackets(builder)
            return builder.close()
        self.lbracket(builder)
        builder.data(" ")
        len_minus_one = len(params) - 1
        for i in range(len(params)):
            param = params[i]
            self.build_param(builder, param)
            if i < len_minus_one:
                builder.data(", ")
        builder.data(" ")
        self.rbracket(builder)
        builder.end("span")
        return builder.close()

    def build_parameter(self, parameter: str) -> Element:
        builder: TreeBuilder = TreeBuilder()
        builder.start("span", {"class": "param"})
        builder.data(parameter)
        builder.end("span")
        return builder.close()

    def build_param(self, builder: TreeBuilder, definition: dict, short = False, type = True):
        if "type" in definition and not short and type:
            self.build_node(builder, definition["type"])
            builder.data(" ")
        self.build_node(builder, definition["name"])
        if "default" in definition and not short:
            builder.data(" = ")
            self.build_node(builder, definition["default"])
    
    def build_node(self, builder: TreeBuilder, definition: dict):
        has_class = "class" in definition
        has_href = "href" in definition
        has_tooltip = "tooltip" in definition
        if has_href:
            builder.start("a", {"href": definition["href"]})

        tag = "span"
        attributes = {}
        if has_class or has_tooltip:
            if has_class:
                attributes["class"] = definition["class"]
            if has_tooltip:
                tag = "abbr"
                attributes["title"] = definition["tooltip"]
            builder.start(tag, attributes)

        builder.data(definition["text"])
        
        if has_class or has_tooltip:
            builder.end(tag)

        if has_href:
            builder.end("a")
    
    def lbracket(self, builder: TreeBuilder):
        builder.start("span", {"class": "bracket"})
        builder.data("(")
        builder.end("span")
    
    def rbracket(self, builder: TreeBuilder):
        builder.start("span", {"class": "bracket"})
        builder.data(")")
        builder.end("span")
    
    def brackets(self, builder: TreeBuilder):
        builder.start("span", {"class": "bracket"})
        builder.data("( )")
        builder.end("span")
    
    def fix_url(self, url: str) -> str:
        if url.startswith("http"):
            return url
        return self.md.Meta["root"][0] + "/" + url
        


class ClassMemberPreprocessor(Preprocessor):
    def __init__(self, md, class_url_provider):
        super().__init__(md)
        self.class_url_provider = class_url_provider

    def run(self, lines):
        class_members = {}
        if (hasattr(self.md, 'Meta')):
            if 'properties' in self.md.Meta:
                meta_properties = self.md.Meta['properties']
                properties = {}
                for property in meta_properties:
                    if ":" in property:
                        split_property = [entry.strip() for entry in property.split(":", 1)]
                        prop_name = split_property[0]
                        if "=" in split_property[1]:
                            split_type_value = [entry.strip() for entry in split_property[1].split("=", 1)]
                            properties[prop_name] = {
                                "name": self.build_property(prop_name),
                                "type": self.build_type(split_type_value[0]),
                                "default": self.build_default(split_type_value[1])
                            }
                        else:
                            properties[prop_name] = {
                                "name": self.build_property(prop_name),
                                "type": self.build_type(split_property[1])
                            }
                    else:
                        if "=" in property:
                            split_property = [entry.strip() for entry in property.split("=", 1)]
                            prop_type_name = split_property[0]
                            if " " in prop_type_name:
                                split_type_name = [entry.strip() for entry in prop_type_name.split(" ", 1)]
                                prop_name = split_type_name[1]
                                properties[prop_name] = {
                                    "name": self.build_property(prop_name),
                                    "type": self.build_type(split_type_name[0]),
                                    "default": self.build_default(split_property[1])
                                }
                            else:
                                properties[prop_type_name] = {
                                    "name": self.build_property(prop_type_name),
                                    "default": self.build_default(split_property[1])
                                }
                        else:
                            if " " in property:
                                split_type_name = [entry.strip() for entry in property.split(" ", 1)]
                                prop_name = split_type_name[1]
                                properties[prop_name] = {
                                    "name": self.build_property(prop_name),
                                    "type": self.build_type(split_type_name[0])
                                }
                            else:
                                properties[property] = {
                                    "name": self.build_property(property)
                                }
                class_members["properties"] = properties

            if 'constants' in self.md.Meta:
                meta_constants = self.md.Meta['constants']
                constants = {}
                for constant in meta_constants:
                    if ":" in constant:
                        split_constant = [entry.strip() for entry in constant.split(":", 1)]
                        const_name = split_constant[0]
                        if "=" in split_constant[1]:
                            split_type_value = [entry.strip() for entry in split_constant[1].split("=", 1)]
                            constants[const_name] = {
                                "name": self.build_constant(const_name),
                                "type": self.build_type(split_type_value[0]),
                                "default": self.build_default(split_type_value[1])
                            }
                        else:
                            constants[const_name] = {
                                "name": self.build_constant(const_name),
                                "type": self.build_type(split_constant[1])
                            }
                    else: 
                        if "=" in constant:
                            split_constant = [entry.strip() for entry in constant.split("=", 1)]
                            const_type_name = split_constant[0]
                            if " " in const_type_name:
                                split_type_name = [entry.strip() for entry in const_type_name.split(" ", 1)]
                                const_name = split_type_name[1]
                                constants[const_name] = {
                                    "name": self.build_constant(const_name),
                                    "type": self.build_type(split_type_name[0]),
                                    "default": self.build_default(split_constant[1])
                                }
                            else:
                                constants[const_type_name] = {
                                    "name": self.build_constant(const_type_name),
                                    "default": self.build_default(split_constant[1])
                                }
                        else:
                            if " " in constant:
                                split_type_name = [entry.strip() for entry in constant.split(" ", 1)]
                                const_name = split_type_name[1]
                                constants[const_name] = {
                                    "name": self.build_constant(const_name),
                                    "type": self.build_type(split_type_name[0])
                                }
                            else:
                                constants[constant] = {
                                    "name": self.build_constant(constant)
                                }
                class_members["constants"] = constants
            
            if 'enums' in self.md.Meta:
                enums = {}
                meta_enums = self.md.Meta['enums']
                for meta_enum in meta_enums:
                    name_consts = [entry.strip() for entry in meta_enum.split(" ", 1)]
                    enum_name = name_consts[0]
                    raw_entries = [entry.strip() for entry in name_consts[1][1:-1].split(",")]
                    enum_entries = [self.build_enum_entry(entry.strip()) for entry in raw_entries]
                    enums[enum_name] = {
                        "name": self.build_enum(enum_name),
                        "entries": enum_entries,
                        "entry_map": {name: data for name, data in zip(raw_entries, enum_entries)}
                    }
                class_members["enums"] = enums

            if 'methods' in self.md.Meta:
                methods = {}
                meta_methods = self.md.Meta['methods']
                for meta_method in meta_methods:
                    signature = {}
                    if meta_method.startswith("static "):
                        meta_method = meta_method[7:]
                        signature["static"] = {
                            "text": "static",
                            "class": "static"
                        }
                    returntype_method = re.search(r"^[a-zA-Z _.]*", meta_method).group().strip().split(" ")
                    if (len(returntype_method)) == 1:
                        method_name = returntype_method[0]
                        signature["method"] = self.build_method_name(method_name)
                    else:
                        method_name = returntype_method[1]
                        signature["return_type"] = self.build_type(returntype_method[0])
                        signature["method"] = self.build_method_name(method_name)
                    params = self.split_params(re.search(r"\((([a-zA-Z0-9_ :.]*([=][^=]*[=][ ]*)?)[,)])+", meta_method).group()[1:-1])
                    if len(params) == 1 and params[0].strip() == "":
                            signature["params"] = []
                            methods[method_name] = signature
                            continue
                    param_sigs = []
                    for param in params:
                        param_sig = {}
                        if "=" in param:
                            param_default = [entry.strip() for entry in param.rstrip("= ").split("=")]
                            param = param_default[0]
                            param_sig["default"] = self.build_default(param_default[1])
                        if ":" in param:
                            split_param = [entry.strip() for entry in param.split(":")]
                            param_sig["name"] = self.build_param(split_param[0])
                            param_sig["type"] = self.build_type(split_param[1])
                        else:
                            split_param = param.strip().split(" ")
                            if len(split_param) == 1:
                                param_sig["name"] = self.build_param(split_param[0])
                            else:
                                param_sig["name"] = self.build_param(split_param[1])
                                param_sig["type"] = self.build_type(split_param[0])
                        param_sigs.append(param_sig)
                    signature["params"] = param_sigs
                    methods[method_name] = signature
                class_members["methods"] = methods

            if 'signals' in self.md.Meta:
                signals = {}
                meta_signals = self.md.Meta['signals']
                for meta_signal in meta_signals:
                    signature = {}
                    signal = re.search("^[a-zA-Z _]*", meta_signal).group().strip()
                    signature["signal"] = self.build_signal_name(signal)
                    params = re.search(r"\((([a-zA-Z0-9_ :.]*([=][^=]*[=][ ]*)?)[,)])+", meta_signal).group()[1:-1].split(",")
                    if len(params) == 1 and params[0].strip() == "":
                            signature["params"] = []
                            signals[signal] = signature
                            continue
                    param_sigs = []
                    for param in params:
                        param_sig = {}
                        if "=" in param:
                            param_default = [entry.strip() for entry in param.rstrip("= ").split("=")]
                            param = param_default[0]
                            param_sig["default"] = self.build_default(param_default[1])
                        if ":" in param:
                            split_param = [entry.strip() for entry in param.split(":")]
                            param_sig["name"] = self.build_param(split_param[0])
                            param_sig["type"] = self.build_type(split_param[1])
                        else:
                            split_param = param.strip().split(" ")
                            if len(split_param) == 1:
                                param_sig["name"] = self.build_param(split_param[0])
                            else:
                                param_sig["name"] = self.build_param(split_param[1])
                                param_sig["type"] = self.build_type(split_param[0])
                        param_sigs.append(param_sig)
                    signature["params"] = param_sigs
                    signals[signal] = signature
                class_members["signals"] = signals
        self.md.class_members = class_members
        return lines
    
    def build_type(self, type: str) -> dict:
        if not "." in type:
            definition = {"text": type}
            if type == "void":
                definition["class"] = "void"
            else:
                definition["class"] = "type"
                definition["href"] = self.fix_url(self.class_url_provider.get_href(type))
            return definition
        else:
            parts = type.split(".")
            return {
                "text": parts[1],
                "class": "type",
                "href": self.fix_url(self.class_url_provider.get_href(parts[0])) + "#" + parts[1]
                }
    
    def build_method_name(self, method: str) -> dict:
        return {
            "text": method,
            "class": "method",
            "href": "#" + method
        }
    
    def build_signal_name(self, signal: str) -> dict:
        return {
            "text": signal,
            "class": "signal",
            "href": "#" + signal
        }

    def build_param(self, param: str) -> dict:
        if (param.endswith("...")):
            return {
                "text": param,
                "class": "param",
                "tooltip": "This is a varags parameter. Due to the implementation it accepts up to 10 arguments."
            }
        return {
            "text": param,
            "class": "param"
        }
    
    def build_default(self, default: str) -> dict:
        return {
            "text": default,
            "class": "default"
        }

    def build_property(self, property: str) -> dict:
        return {
            "text": property,
            "class": "prop",
            "href": "#" + property
        }

    def build_constant(self, constant: str) -> dict:
        return {
            "text": constant,
            "class": "constant"
            #"href": "#" + constant # no need to have descriptions for individual constants
        }
    
    def build_enum(self, enum_name: str) -> dict:
        return {
            "text": enum_name,
            "class": "enum"
        }
    
    def build_enum_entry(self, entry: str) -> dict:
        return {
            "text": entry,
            "class": "enum_entry"
        }

    def fix_url(self, url: str) -> str:
        if url.startswith("http"):
            return url
        return self.md.Meta["root"][0] + "/" + url
    
    def split_params(self, params_str):
        if len(params_str) == 0:
            return []
        params = []
        inside_default_param = False
        last_comma = -1
        for index in range(0, len(params_str)):
            match params_str[index]:
                case '=':
                    inside_default_param = not inside_default_param
                case ',':
                    if inside_default_param:
                        continue
                    params.append(params_str[last_comma + 1:index])
                    last_comma = index
        params.append(params_str[last_comma + 1:])
        return params

def makeExtension(**kwargs):
    return ClassMemberExtension(**kwargs)