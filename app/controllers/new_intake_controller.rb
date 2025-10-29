class NewIntakeController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    # Convert params to hash with string keys for YAML
    matter_data = convert_params_to_yaml_format(new_intake_params)

    # Append to YAML file
    append_to_yaml_file(matter_data)

    render json: { status: "success" }, status: :created
  rescue => e
    render json: {
      status: "error",
      message: e.message
    }, status: :unprocessable_entity
  end

  private

  def new_intake_params
    params.require(:new_intake).permit(
      :matter_number, :title, :client_name, :client_type, :practice_area,
      :matter_type, :status, :opened_date, :closed_date, :assigned_attorney,
      :description, :conflict_check_completed_date, adverse_parties: [], related_parties: []
    )
  end

  def convert_params_to_yaml_format(params_hash)
    matter_data = {}

    params_hash.each do |key, value|
      string_key = key.to_s
      if value.nil? || (value.is_a?(String) && value.empty?)
        matter_data[string_key] = nil
      elsif value.is_a?(Array)
        matter_data[string_key] = value.compact
      else
        matter_data[string_key] = value
      end
    end

    matter_data
  end

  def append_to_yaml_file(matter_data)
    yaml_file_path = Rails.root.join("legal_matter_mocks.yml")

    # Read existing YAML data
    existing_data = YAML.load_file(yaml_file_path)
    existing_data["legal_matters"] ||= []

    # Append new matter
    existing_data["legal_matters"] << matter_data

    # Write back to file
    File.open(yaml_file_path, "w") do |file|
      file.write(YAML.dump(existing_data))
    end
  end
end
