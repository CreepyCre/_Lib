class_name UpdateChecker

class AlphabeticalComparator: const import = "util/Strings/AlphabeticalComparator"
class UiBuilder: const import = "util/UiBuilder/"

const CLASS_NAME = "UpdateChecker"
var LOGGER: Object

var _util
var _item_agents = {}
var _item_to_agent = {}
var _mod_versions_window
var _mv_tree: Tree
var _show_mod_versions: Once = Once.new()

func _init(logger: Object, util, loader, mod_registry):
    LOGGER = logger.for_class(self)
    _util = util

    _mod_versions_window = loader.load_scene("ModVersions").instance()
    util.add_window(_mod_versions_window)
    # aquire sorted ddmods
    var ddmods: Dictionary = mod_registry.get_ddmods()
    var ddmod_array: Array = ddmods.values()
    ddmod_array.sort_custom(self, "_sort_ddmod_array")
    # set up the mod versions tree
    _mv_tree = _mod_versions_window.get_node("MarginContainer/VBoxContainer/Mods")
    _mv_tree.connect("button_pressed", self, "_update_clicked")
    _mv_tree.set_column_titles_visible(true)
    _mv_tree.set_column_title(0, "Mod")
    _mv_tree.set_column_title(1, "Current Version")
    _mv_tree.set_column_title(2, "Recent Version")
    _mv_tree.set_column_min_width(3, 32)
    _mv_tree.set_column_expand(3, false)
    var root = _mv_tree.create_item()
    for ddmod in ddmod_array:
        var mod_id = ddmod["unique_id"]
        var current_version = ddmod["version"]
        var item = _mv_tree.create_item(root)
        var agent = ItemAgent._new(LOGGER, item)
        _item_agents[mod_id] = agent
        _item_to_agent[item] = agent
        item.set_text(0, ddmod["name"])
        item.set_text(1, ddmod["version"])

func _update_clicked(item, _column, _id):
    _item_to_agent[item].download()

func _sort_ddmod_array(a, b):
    return AlphabeticalComparator.compare(a["name"], b["name"]) == -1

func register(mod_id: String, agent: UpdateAgent):
    _item_agents[mod_id].set_update_agent(agent)
    _item_agents[mod_id].item.set_icon(2, Global.Theme.get_icon("Throbber", "CreepyCre._Lib"))
    agent.fetch_version(funcref(_item_agents[mod_id], "version_callback"))

func _update(_delta):
    if _show_mod_versions.once():
        _mod_versions_window.popup_centered()

func _instance(mod_info):
    var instance = InstancedUpdateChecker._new(self, mod_info)
    return instance

class ItemAgent:
    var LOGGER
    var item: TreeItem
    var update_agent: UpdateAgent
    var recent_version

    func _init(logger, item):
        self.LOGGER = logger
        self.item = item

    func set_update_agent(agent):
        self.update_agent = agent
    
    func version_callback(result):
        if result.is_exception():
            item.set_icon(2, Global.Theme.get_icon("StatusError", "EditorIcons"))
            item.set_text(2, "Error")
            LOGGER.error("Could not fetch recent version for {mod}. Reason: {reason}".format({"mod": item.get_text(0), "reason": result.get_exception()}))
            return
        recent_version = result.get_value()
        item.set_text(2, recent_version)
        if update_agent.get_current_version() != null and update_agent.compare(update_agent.get_current_version(), recent_version) != -1:
            item.set_icon(2, Global.Theme.get_icon("StatusSuccess", "EditorIcons"))
            return
        item.set_icon(2, Global.Theme.get_icon("StatusWarning", "EditorIcons"))
        item.add_button(3, Global.Theme.get_icon("Button", "EditorIcons"), -1, false, "Open Download URL")

    func download():
        update_agent.download(recent_version)
        

class InstancedUpdateChecker:
    class SemVer: const import = "util/SemVer/"

    var _update_checker
    var _mod_id
    var _version
    
    func _init(update_checker, mod_info):
        _update_checker = update_checker
        _mod_id = mod_info.mod_meta["unique_id"]
        _version = mod_info.mod_meta["version"]
    
    func register(agent: UpdateAgent):
        _update_checker.register(_mod_id, agent)
    
    func builder() -> UpdateAgentBuilder:
        var version = SemVer._new(_version) if SemVer.is_sem_ver(_version) else null
        return UpdateAgentBuilder.new().version(version)
    
    func github_fetcher(owner: String, repo: String, version_parser = null):
        return GitHubFetcher._new(_update_checker._util, owner, repo) if version_parser == null else GitHubFetcher._new(_update_checker._util, owner, repo, version_parser)
    
    func github_downloader(owner: String, repo: String):
        return GitHubDownloader._new(owner, repo)

class UpdateAgent:
    var current_version
    var comparator
    var version_fetcher
    var downloader

    func _init(current_version, comparator, version_fetcher, downloader):
        self.current_version = current_version
        self.comparator = comparator
        self.version_fetcher = version_fetcher
        self.downloader = downloader
    
    func get_current_version():
        return current_version
    
    func compare(v1, v2):
        return comparator.call_func(v1, v2)

    func fetch_version(callback):
        version_fetcher.call_func(callback)
    
    func download(version):
        downloader.call_func(version)

class UpdateAgentBuilder:
    class SemVer: const import = "util/SemVer/"

    var _current_version = ""
    var _comparator = funcref(SemVer, "compare")
    var _version_fetcher = null
    var _downloader = null

    func build() -> UpdateAgent:
        return UpdateAgent.new(_current_version, _comparator, _version_fetcher, _downloader)

    func version(current_version):
        _current_version = current_version
        return self
    
    func comparator(comparator):
        _comparator = comparator
        return self
    
    func fetcher(version_fetcher):
        _version_fetcher = version_fetcher
        return self

    func downloader(downloader):
        _downloader = downloader
        return self

class GitHubFetcher:
    class SemVer: const import = "util/SemVer/"

    const URL_LATEST = "https://api.github.com/repos/{owner}/{repo}/releases/latest"

    var util
    var owner: String
    var repo: String
    var version_parser

    func _init(util, owner, repo, version_parser = funcref(self, "parse_version")):
        self.util = util
        self.owner = owner
        self.repo = repo
        self.version_parser = version_parser
    
    func call_func(callback):
        util.single_use_http_request(Callback.new(funcref(self, "_fetch_callback"), callback))\
            .request(URL_LATEST.format({"owner": owner, "repo": repo}))
        
    func _fetch_callback(http_request: HTTPRequest, result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, callback):
        if result != HTTPRequest.RESULT_SUCCESS:
            callback.call_func(Result.exception("HTTPS request failed."))
            return
        var json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
        if json.error != OK:
            callback.call_func(Result.exception("JSON error."))
            return
        if json.result.has("status") and json.result["status"] == "404":
            callback.call_func(Result.exception("Repository does not have any releases."))
            return
        if json.result.has("message") and json.result["message"].begins_with("API rate limit exceeded"):
            callback.call_func(Result.exception("API rate limit exceeded."))
            return
        if not json.result.has("tag_name"):
            callback.call_func(Result.exception("Response does not contain version."))
            return
        callback.call_func(version_parser.call_func(json.result["tag_name"]))
    
    func parse_version(tag: String) -> Result:
        print(tag)
        if not SemVer.is_sem_ver(tag):
            return Result.exception("Version tag \"{tag}\" is not SemVer.".format({"tag": tag}))
        return Result.of(SemVer._new(tag.lstrip("v")))

class GitHubDownloader:
    const URL_LATEST = "https://github.com/{owner}/{repo}/releases/latest"
    
    var owner: String
    var repo: String
    var prepend_v: bool

    func _init(owner: String, repo: String):
        self.owner = owner
        self.repo = repo
        self.prepend_v = prepend_v

    func call_func(version):
        OS.shell_open(URL_LATEST.format({"owner": owner, "repo": repo}))


class Callback:
    var callback1
    var callback2
    
    func _init(c1, c2):
        callback1 = c1
        callback2 = c2
    
    func call_func(http_request, result, response_code, headers, body):
        callback1.call_func(http_request, result, response_code, headers, body, callback2)

# TODO: move into own class
class Once:
    var has_triggered: bool = false

    func once() -> bool:
        if has_triggered:
            return false
        has_triggered = true
        return true

class Result:
    func is_exception() -> bool:
        assert(false)
        return true # satisfy the language server
    
    func get_value():
        assert(false)
    
    func get_exception() -> String:
        assert(false)
        return "" # satisfy the language server

    static func of(value) -> Result:
        return ValueResult.new(value)

    static func exception(msg: String) -> Result:
        return ExceptionResult.new(msg)

class ValueResult:
    extends Result

    var value

    func _init(value):
        self.value = value

    func is_exception() -> bool:
        return false
    
    func get_value():
        return value

class ExceptionResult:
    extends Result

    var exception: String

    func _init(exception: String):
        self.exception = exception
    
    func is_exception() -> bool:
        return true

    func get_exception() -> String:
        return exception