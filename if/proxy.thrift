namespace go proxy

struct ProxyConfig {
  1: string redis_ip
  2: i32 ttl_ms
  3: i32 capacity
  4: i32 port
  5: i32 connections
  6: i32 spooling
}

struct SpoolerConfig {
  1: string redis_ip
}

struct CacheConfig {
  2: i32 ttl_ms
  3: i32 capacity
  6: i32 spooler_id
}

struct DisposalConfig {
  2: i64 ttl_mus
  3: i32 capacity
}

struct CacheableValue {
  1: string key
  2: string value
  3: i32 fetched_time
}

exception RedisUnavailable {
  1: string redis_ip
}

service RedisProxy {
  bool initialize(1: ProxyConfig config)
  string getValue(1: string key)
}

service RedisCache {
  bool initialize(1: CacheConfig config)
  string getValue(1: string key)
}

service RedisSpooler {
  bool initialize(1: SpoolerConfig config)
  CacheableValue getValue(1: string key)
}

service RedisDisposal {
  bool initialize(1: DisposalConfig config)
  bool cleanCache()
}
