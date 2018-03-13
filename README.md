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
