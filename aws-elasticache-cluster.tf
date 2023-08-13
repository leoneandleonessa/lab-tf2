resource "aws_elasticache_cluster" "memcached" {
  cluster_id                   = "tempo-memcached-cluster"
  engine                       = "memcached"
  node_type                    = "cache.t3.medium"
  num_cache_nodes              = 2
  parameter_group_name         = "default.memcached1.6"
  port                         = 11211
  preferred_availability_zones = module.vpc.azs
  subnet_group_name            = aws_elasticache_subnet_group.memcached.name
  security_group_ids           = [aws_security_group.memcached.id]
}