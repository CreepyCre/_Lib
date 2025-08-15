class AlphabeticalComparator:
    static func compare(str1, str2):
        var str1_bytes: PoolByteArray = str1.to_ascii()
        var str2_bytes: PoolByteArray = str2.to_ascii()
        var max_bytes_size: int = int(min(str1_bytes.size(), str2_bytes.size()))
        var j: int = 0
        while j < max_bytes_size:
            j = j + 1
            if str1_bytes[j] == str2_bytes[j]:
                continue
            return -1 if str1_bytes < str2_bytes else 1
        if str1_bytes.size() != str2_bytes.size():
            return -1 if str1_bytes.size() < str2_bytes.size() else 1
        return 0
    
    static func call_func(str1, str2):
        return compare(str1, str2)