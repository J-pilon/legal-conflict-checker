module FeatureFlaggable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def feature_flaggable(flag_name:)
      @feature_flag_name = flag_name
    end

    def feature_flag_name
      @feature_flag_name
    end

    # Configure which methods should be intercepted when flag is disabled
    def mock_when_disabled(*methods)
      methods.each do |method_name|
        if instance_methods.include?(method_name) && !instance_methods.include?(:"_original_#{method_name}")
          alias_method :"_original_#{method_name}".to_sym, method_name
        end

        define_method(method_name) do |*args, **kwargs, &block|
          flag_enabled = FeatureFlags.const_get(self.class.feature_flag_name)

          if flag_enabled
            method("_original_#{method_name}").call(*args, **kwargs, &block)
          else
            mock_method = "mock_#{method_name}".to_sym
            if respond_to?(mock_method, true)
              send(mock_method, *args, **kwargs, &block)
            else
              []
            end
          end
        end
      end
    end
  end
end
