class Attorney
  attr_reader :name, :business_interests

  def initialize(attorney)
    @name = attorney["name"]
    @business_interests = attorney["business_interests"]
  end

  class << self
    def all
      attorney_mocks = Rails.root.join("attorney_mocks.yml")
      YAML.load_file(attorney_mocks)["attorneys"].map { |attorney| new(attorney) }
    end

    def find_by_name(name)
      all.find { |attorney| attorney.name == name }
    end
  end
end
