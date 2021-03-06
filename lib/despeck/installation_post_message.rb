# frozen_string_literal: true

module Despeck
  # Print notes from the installation
  module InstallationPostMessage
    module_function

    def build
      if %w[1 true TRUE].include?(
        ENV.fetch('DESPECK_SKIP_INSTALL_NOTES', false)
      )
        return
      end

      require 'vips'
      return print_notes unless vips_check_passed?
    end

    def vips_support_pdf?
      begin
        Vips::Image.pdfload
      rescue Vips::Error => e
        if e.message =~ /class "pdfload" not found/
          notes << <<~DOC
            - Libvips is installed without PDF support. Make sure you
              have PDFium/poppler-glib installed before installing
              despeck. For more details on installation please see:
              https://libvips.github.io/libvips/install.html
          DOC
          return false
        end
      end
      true
    end

    def vips_version_supported?
      version_only = Vips.version_string.match(/(\d+\.\d+\.\d+)/)[0]

      min_version = '8.6.5'
      return true if Gem::Version.new(version_only) > Gem::Version.new(min_version)

      notes << <<~DOC
        - Your libvips version must be newer than version #{min_version}.
          Please rebuild/reinstall your libvips to >= #{min_version}.
      DOC
      false
    end

    def vips_check_passed?
      passed = true
      passed = false unless vips_version_supported?
      passed = false unless vips_support_pdf?
      passed
    end

    def notes
      @notes ||= []
    end

    def print_notes
      return if notes.empty?

      puts <<~NOTES
        #{hr '='}
          Despeck Installation Notes :
        #{hr '-'}
        #{notes.uniq.join("\n")}
          To Skip this notes `export DESPECK_SKIP_INSTALL_NOTES=1`
        #{hr '='}
      NOTES
      @error_message = []
      false
    end

    def hr(line = '-')
      (line * 50)
    end
  end
end
