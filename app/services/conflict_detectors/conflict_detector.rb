module ConflictDetectors
  class ConflictDetector
    attr_reader :prospective_matter, :former_matter

    def initialize(former_matter, prospective_matter)
      @prospective_matter = prospective_matter
      @former_matter = former_matter
    end

    def detect
      raise NotImplementedError, "You must implement the detect method"
    end

    class << self
      def descendants
        [
          ConcurrentConflictDetector,
          LawyerClientConflictDetector,
          SuccessiveConflictDetector
        ]
      end
    end
  end
end
