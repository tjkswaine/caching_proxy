# caching_proxy

## Execution of exercise notes
Starting with no familiarity with Go or with Redis or with Docker beyond cultural significance and the abstractions they are rumored to empower. 

Considering Haskell as an alternative I have familiarity with.

Looking at Redis, it would appear that a local instance of Redis would be a good design for timed, LRU eviction cache.

Strategy notes:
* Use allkeys_lru eviction policy
* Set TTL upon SET's. I interpret the Global eviction policy as being motivated by mutations in source data. As a result, the TTL should not be reset after GET's.
* Exectuion of GET:
  1. Try to GET from local Redis, return value upon success.
  2. Try to GET from source of truth, SET local Redis (along with TTL) and return value (perhaps (nil).
* Caching nil? Yes. The goal of the proxy is to elide network calls to the main cluster if possible. nil should be cached along with non-nil values. Problem is (nil) from local redis will fail step 1. Can we encode a nil effectively without potentiall collisions with actual data? Can prefix actual data with char which is excluded from nil.  So "(nil)" stores as "+(nil)" but (nil) stores as "(nil)". A hack, but it will work.
* Get is not only API access method without side-effects.
  * STRING: GET, BITCOUNT, BITFIELD, BITPOS, GETBIT, GETRANGE, MGET, STRLEN
  * GEO: GEOHASH, GEOPOS, GEODIST, GEORADIUS, GEORADIUSBYMEMBER,
  * HASHES: HEXIST, HGET, HGETALL, HKEYS, HLEN, HMGET, HSTRLEN, HVALS, HSCAN
  * HLL: PFCOUNT
  * LIST: LRANGE, LINDEX, LLEN, 
  * SET: SMEMBERS, SCARD, SDIFF, SINTER, SISMEMBER, SRANDMEMBER, SUNION, SSCAN,
  * SORTED SET: (see above), ZLEXCOUNT, ZREVRANGEBYLEX, ZRANGEBYSCORE, ZRANK, ZREVRANGE, ZREVRANGEBYSCORE, ZREVRANK, ZSCORE, ZSCAN
  * KEY: EXISTS, PTTL, RANDOMKEY, SORT, TYPE, SCAN
* Re-reading spec: "If the local cache
does not contain a value for the specified key, it fetches the value from the backing
Redis instance, using the Redis GET command, and stores it in the local cache,
associated with the specified key." This means there is no consistency concern and the rest of the side-effect free API is irrelevant. Plan can proceed.
* Caching nil (revised) use LIST for local Cache type. One or two ENTRIES per LIST. Second entry is value.
* Maxmemory and allkeys-lru won't work. At (up to) half a gig per string it is very unlikely that we will run into memory pressure when the cache size is specified by number of keys. That said, we will have to allow "stupid" usage, where a number of locally cached keys is specified and the cache doesn't have enough memory. What to do in this case? Since this is a local cache, we don't want to run up against an amount of memory that will interfere with our other operations. Docker will put bounds on the memory resources of our local Redis, so I would suppose that we have two choices: 
  * Let local Redis run out of memory or 
  * evict when memory is insufficient. 
  Even if we rebuilt the caching native to the language we use, this choice about memory pressure remains. Since we don't want the proxy to fail because the cache was overloaded, I am inclined to choose the more stable eviction strategy. This will violate the terms of the spec in the "stupid" edge case, but we can communincate that in the deliverable. I think this should involve an optional set of params for the percentage of the the container memory that will be the threshold for eviciton (80% default?) and the amount of container space for the process (very little).

