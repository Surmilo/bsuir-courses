require_relative './gem-version'

module GemVersionsFilter
  class VersionFilterDescriptor
    DESC_PATTERN = /(?<cond>>=?|~>|<=?)?\s*(?:(?<vers>\d+\.\d+\.\d+(\.\w+)?))/

    attr_reader :version, :condition

    def initialize(version, condition)
      @version = version
      @condition = condition
    end

    def match?(checked_version)
      case condition
      when '~>' then self.match_tilde_range(checked_version, version)
      when '>=' then checked_version >= version
      when '<=' then checked_version <= version
      when '<' then checked_version < version
      when '>' then checked_version > version
      else checked_version == version
      end
    end

    def match_tilde_range(checked_version, check_version)
      major_vers = GemVersion.new(check_version.major + 1, 0, 0)
      minor_vers = GemVersion.new(check_version.major, 0, 0)

      minor_vers <= checked_version && checked_version <= major_vers
    end

    def self.parse(expression) # '> vers', '~> vers', '<= vers'...
      matched = DESC_PATTERN.match(expression)
      version = GemVersion.parse(matched[:vers])
      condition = matched[:cond]

      VersionFilterDescriptor.new(version, condition)
    rescue StandardError => error
      puts "Exception was handled #{error}"
    end
  end
end
