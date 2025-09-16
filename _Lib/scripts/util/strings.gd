class AlphabeticalComparator:
    static func compare(str1, str2):
        return str1.casecmp_to(str2)
    
    static func call_func(str1, str2):
        return compare(str1, str2)