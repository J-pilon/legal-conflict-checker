module FeatureFlags
  CONFLICT_COLLECTOR_ENABLED = ENV.fetch("CONFLICT_COLLECTOR_ENABLED", "true").casecmp?("true")
end
