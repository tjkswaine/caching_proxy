# caching_proxy

## Execution of exercise notes
Starting with no familiarity with Go or with Redis. 

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
