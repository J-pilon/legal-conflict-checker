class LegalMatter
  attr_reader :matter_number, :title, :client_name, :client_type, :practice_area,
              :matter_type, :status, :opened_date, :closed_date, :adverse_parties,
              :related_parties, :description

  def initialize(attrs)
    @matter_number = attrs["matter_number"]
    @title = attrs["title"]
    @client_name = attrs["client_name"]
    @client_type = attrs["client_type"]
    @practice_area = attrs["practice_area"]
    @matter_type = attrs["matter_type"]
    @status = attrs["status"]
    @opened_date = attrs["opened_date"]
    @closed_date = attrs["closed_date"]
    @adverse_parties = attrs["adverse_parties"]
    @related_parties = attrs["related_parties"]
    @assigned_attorney = attrs["assigned_attorney"]
    @description = attrs["description"]
  end

  def assigned_attorney
    Attorney.find_by_name(@assigned_attorney)
  end

  class << self
    def all
      legal_matter_mocks = Rails.root.join("legal_matter_mocks.yml")
      YAML.load_file(legal_matter_mocks)["legal_matters"].map { |legal_matter_data| new(legal_matter_data) }
    end
  end
end
