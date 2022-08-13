
# Let's import the libraries we will need
import findspark
findspark.init()
import pyspark
from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark import SparkContext, SparkConf

import itertools
# create the session
conf = SparkConf().set("spark.ui.port", "4050")
# create the context
sc = pyspark.SparkContext(conf=conf)
spark = SparkSession.builder.getOrCreate()

# check if combination in previous frequents
def isPresent(combination, u, i):
    if i==2:
        subs = [x for x in combination]
    else:
        subs = [tuple(sorted(comb)) for comb in itertools.combinations(combination, i-1)]
    # return subs.issubset(prevFreq)
    present = [False]*len(subs)
#     for j in range(len(subs)):
#         present2 = [False]*len(subs[j])
#         for k in range(len(subs[j])):
#             present2[k] = subs[j][k] in u
#         present1[j]= all(present2)
    for j in range(len(subs)):
        present[j] = subs[j] in u
#     if all(present):
#         print('present at iter', i , combination, subs ,all(present))
    return all(present)

def f(row, arr):
    hazir= []
    for key in arr:
        present = [False]*len(key)
        for i in range(len(key)):
            present[i] = key[i] in row
        if all(present):
            hazir+=[key]
    return hazir

def getSingles(lines, support):
    supCount = len(list(lines))*support
    dist = set([])
    for line in lines:
      for word in line:
          dist.add(word)
    counts = dict(zip(dist, [0]*len(list(dist))))
    combinations = []
    for line in lines:
      for word in line:
        counts[word] +=1
    for w, c in counts.items():
        if (c>=supCount):
            combinations += [w]
    return combinations

def getfilteredCombos(partition, freq, support, i):
    lines = list(partition)
    supCount = len(lines)*support
    my_combinations = set([])
    #get combinations
    if i==2:
        dist = freq
        my_combinations = set([tuple(sorted(combination)) for combination in itertools.combinations(dist, i) if isPresent(combination, freq, i)])
#           print('my_combinations\n',my_combinations)
    else:
        
        dist = set([])
        for y in freq:
            for x in y:
                dist.add(x)
#             print('distinct[0]\n',dist)
        my_combinations= set([tuple(sorted(combination)) for combination in list(itertools.combinations(list(dist), i)) if isPresent(combination, freq, i)])
            #filter combinations
           
    counts = dict(zip(my_combinations, [0]*len(my_combinations)))
    for combination in my_combinations:
      present = [False]*len(combination)
      for i in range(len(combination)):
          for line in lines: 
            if combination[i] in line:
                present[i] = True
            if all(present):
                counts[combination] +=1

    for w, c in counts.items():
      if (c>=supCount):
          my_combinations.add(w)

    return list(my_combinations)

def apriori(iterator):
    partition = []
    for v in iterator:
        partition.append(v)
    support = 0.22
    results= getSingles(partition, support)
    # print('starting with', results)

    for i in range(2, 11):
        print('===============sequence length=============' ,i)
    
        combos = getfilteredCombos(partition, results, support, i)
        print('freq', combos)

        if len(combos) == 0:
            print('ending at sequence length' ,i-1)
            return
        results = combos
    return results

rdd1 = sc.textFile("gs://big-data-apriori-algorithm/Dataset.csv").repartition(20)
tagsheader = rdd1.first() 
tags = sc.parallelize(tagsheader)
# tags.collect()
data = rdd1.subtract(tags)
lines = data.map(lambda x: [i.strip().replace('.','') for i in x.split(',') if i not in ''])
freq = lines.mapPartitions(apriori)
# freq = freq.flatMap(lambda x: x).distinct()
# freq.collect()

supC = sc.broadcast(lines.count()*0.22)
comb = sc.broadcast(freq.collect())
freq1 = lines.map(lambda x: [(key, 1) for key in f(x, comb.value)]).filter(lambda x: len(x)>0)
freq2 = freq1.flatMap(lambda x: x).reduceByKey(lambda x, y: x+y).filter(lambda x: x[1]>supC.value).map(lambda x: x[0])
freq2.saveAsTextFile("gs://big-data-apriori-algorithm/output1/")



# with open('output.txt', 'w') as f:
#     for _list in frequent:
#         for _string in _list:
#             #f.seek(0)
#             f.write(str(_string) + '\n')

# # f.close()