#
# String extension file. Changes titleize to not titleize the small words in life.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class String

  #
  # Titleizes a string. Now with added options for exclusions.
  #
  # @param options Options for titleizing: :exclusions for words not to capitalize. Defaults to a standard list of English words.
  # @return The titleized string.
  #
  def titleize(options = {})
    exclusions = %w(a an and at but by can for from is of or the to)
    exclusions = options[:exclusions] if options[:exclusions]

    return ActiveSupport::Inflector.titleize(self) unless exclusions.present?
    self.underscore
      .gsub(/([0-9\d+])([A-Za-z])/, '\1_\2'.freeze)
      .humanize
      .gsub(/\b(?<!['’`])(?!(#{exclusions.join('|')})\b)[a-z]/) { $&.capitalize }
  end
end

