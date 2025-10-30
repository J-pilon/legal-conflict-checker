class AuditController < ApplicationController
  skip_before_action :verify_authenticity_token

  def update
    matter_number = params.dig(:audit, :matter_number)
    action_value = params.dig(:audit, :action)

    yaml_file_path = Rails.root.join("legal_matter_mocks.yml")
    data = YAML.load_file(yaml_file_path)
    records = data["legal_matters"] || []

    index = records.find_index { |m| m["matter_number"].to_s == matter_number.to_s }
    unless index
      render json: { status: "error", message: "Matter not found" }, status: :not_found and return
    end

    record = records[index]
    record["conflict_check"] ||= {}
    record["conflict_check"]["completed_date"] = Date.current.strftime("%Y-%m-%d")
    record["conflict_check"]["action"] = action_value

    File.open(yaml_file_path, "w") do |file|
      file.write(YAML.dump({ "legal_matters" => records }))
    end

    render json: { status: "success" }, status: :ok
  rescue => e
    render json: { status: "error", message: e.message }, status: :internal_server_error
  end
end
