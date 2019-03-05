module ResearchMasterHelper

  def mark_required(object, attribute)
    " *" if object.class.validators_on(attribute).map(&:class).include? ActiveRecord::Validations::PresenceValidator
  end
end
