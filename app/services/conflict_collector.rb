class ConflictCollector
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

  private

  def load_detectors
    ConflictDetectors::ConflictDetector.descendants
  end

  def former_legal_matters
    LegalMatter.all
  end
end
