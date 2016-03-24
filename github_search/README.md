Problem
-------
Write a utility to get a list of all github projects using C or C++.

Note that it has a 1000 result limit, so simply searching by language is not enough. Instead, we will need to search using every combination of prefix strings out to about 3 characters per our existing testing, i.e.:

aaa, aab, aac, …, aba, abc, …, baa, bab, bac, … zzz
