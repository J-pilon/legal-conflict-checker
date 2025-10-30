class ConflictCollector
  include FeatureFlaggable

  feature_flaggable(flag_name: :CONFLICT_COLLECTOR_ENABLED)

  attr_reader :prospective_matter, :detectors

  def self.search(prospective_matter)
    instance = new(prospective_matter)
    instance.search
  end

  def initialize(prospective_matter)
    @prospective_matter = prospective_matter
    @detectors = load_detectors
  end

  def search
    detectors.map do |detector|
      former_legal_matters.filter_map do |former_legal_matter|
        detector.detect(former_legal_matter, prospective_matter)
      end
    end
  end

  # Automatically intercepts when flag is disabled
  mock_when_disabled :search

  private

  def load_detectors
    ConflictDetectors::ConflictDetector.descendants
  end

  def former_legal_matters
    LegalMatter.all
  end
end
