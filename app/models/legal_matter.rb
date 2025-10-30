class LegalMatter
  attr_reader :matter_number, :title, :client_name, :client_type, :practice_area,
              :matter_type, :status, :opened_date, :closed_date, :adverse_parties,
              :related_parties, :description
  attr_accessor :conflicts, :conflict_check

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
    @conflict_check = attrs["conflict_check"]
    @conflicts = nil
  end

  def assigned_attorney
    Attorney.find_by_name(@assigned_attorney)
  end

  def has_completed_conflict_check?
    conflict_check && conflict_check.dig("completed_date").present?
  end

  def conflicts_by_type
    return {} if @conflicts.nil? || @conflicts.empty?

    @conflicts.group_by { |conflict| conflict[:type] }
  end

  def conflicts_count
    @conflicts.nil? ? 0 : @conflicts.length
  end

  class << self
    def all
      legal_matter_mocks = Rails.root.join("legal_matter_mocks.yml")
      YAML.load_file(legal_matter_mocks)["legal_matters"].map { |legal_matter_data| new(legal_matter_data) }
    end
  end
end
