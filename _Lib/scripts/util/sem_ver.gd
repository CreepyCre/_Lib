class_name SemVer

class AlphabeticalComparator: const import = "util/Strings/AlphabeticalComparator"

## https://semver.org/spec/v2.0.0.html

const SEM_VER_REGEX = "^(?<major>[1-9][0-9]*|0)\\.(?<minor>[1-9][0-9]*|0)\\.(?<patch>[1-9][0-9]*|0)(-(?<pre_release>[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*))?(\\+(?<build>[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*))?$"

var major: int
var minor: int
var patch: int
var pre_release: PoolStringArray
var build: PoolStringArray

static func compare(v1, v2):
    if v1.major != v2.major:
        return -1 if v1.major < v2.major else 1
    if v1.minor != v2.minor:
        return -1 if v1.minor < v2.minor else 1
    if v1.patch != v2.patch:
        return -1 if v1.patch < v2.patch else 1
    var max_size: int = int(min(v1.pre_release.size(), v2.pre_release.size()))
    var i: int = 0
    while i < max_size:
        i = i + 1
        var v1_pre: String = v1.pre_release[i]
        var v2_pre: String = v2.pre_release[i]
        if v1_pre == v2_pre:
            continue
        var v1_int: bool = v1_pre.is_valid_integer()
        var v2_int: bool = v2_pre.is_valid_integer()
        if v1_int:
            if v2_int:
                return -1 if v1_pre[i].to_int() < v2_pre.to_int() else 1
            else:
                return -1
        else:
            if v2_int:
                return 1
            else:
                var comp: int = AlphabeticalComparator.compare(v1_pre, v2_pre)
                if comp != 0:
                    return comp
    if v1.pre_release.size() != v2.pre_release.size():
        return -1 if v1.pre_release.size() < v2.pre_release.size() else 1
    return 0

static func is_sem_ver(string: String) -> bool:
        var regex: RegEx = RegEx.new()
        regex.compile(SEM_VER_REGEX)
        return regex.search(string) != null


func _init(major, minor = null, patch = null, pre_release = null, build = null):
    if major is String:
        var regex: RegEx = RegEx.new()
        regex.compile(SEM_VER_REGEX)
        var result = regex.search(major)

        self.major = result.get_string("major").to_int()
        self.minor = result.get_string("minor").to_int()
        self.patch = result.get_string("patch").to_int()
        self.pre_release = result.get_string("pre_release").split(".", false)
        self.build = result.get_string("build").split(".", false)
    else:
        self.major = major
        self.minor = minor
        self.patch = patch
        self.pre_release = pre_release
        self.build = build

func _to_string():
    if pre_release.size() == 0:
        if build.size() == 0:
            return "%s.%s.%s" % [major, minor, patch]
        else:
            return "%s.%s.%s+%s" % [major, minor, patch, build.join(".")]
    else:
        if build.size() == 0:
            return "%s.%s.%s-%s" % [major, minor, patch, pre_release.join(".")]
        else:
            return "%s.%s.%s-%s+%s" % [major, minor, patch, pre_release.join("."), build.join(".")]
            
    