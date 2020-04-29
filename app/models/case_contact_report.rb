class CaseContactReport < ApplicationRecord
  def self.to_csv
    attributes = report_headers

    CSV.generate(headers: true) do |csv|
      csv << attributes.map(&:titleize)

      CaseContact.all.each do |case_contact|
        csv << generate_row(case_contact)
      end
    end
  end

  def self.report_headers
    headers = %w[ internal_contact_number duration contact_type contact_made
                  contact_medium occurred_at added_to_system_at casa_case_number
                  volunteer_email volunteer_name supervisor_name]

    # TODO: Issue 119 -- Enable multiple contact types for a case_contact
    # headers.concat(CaseContact::CONTACT_TYPES.map { |t| "contact_type: #{t}" })
    headers
  end

  def self.generate_row(case_contact)
    row_data = []

    row_data << case_contact_fields(case_contact)
    row_data << casa_case_fields(case_contact.casa_case)
    row_data << volunteer_fields(case_contact.creator)
    row_data << supervisor_fields(case_contact.creator&.supervisor)

    row_data.flatten
  end

  def self.case_contact_fields(case_contact)
    [
      case_contact&.id,
      case_contact&.duration_minutes,
      case_contact&.contact_type,
      case_contact&.contact_made,
      case_contact&.medium_type,
      case_contact&.occurred_at&.strftime('%B %e, %Y'),
      case_contact&.created_at
    ]
  end

  def self.casa_case_fields(casa_case)
    [
      casa_case&.case_number
    ]
  end

  def self.volunteer_fields(volunteer)
    [
      volunteer&.email,
      volunteer&.display_name
    ]
  end

  def self.supervisor_fields(supervisor)
    [
      supervisor&.display_name
    ]
  end
end