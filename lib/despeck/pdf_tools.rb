# frozen_string_literal: true

module Despeck
  # Read/Write PDF files
  module PdfTools
    class << self
      # Increase to improve image quality, decrease to improve performance
      DEFAULT_DPI = 300

      def pdf_to_images(pdf_path, dpi: DEFAULT_DPI)
        images = []
        for_each_page(pdf_path) do |page_no|
          images << Vips::Image.pdfload(pdf_path, page: page_no, dpi: dpi)
        end
        images
      end

      def images_to_pdf(images, pdf_path, origin_images = [])
        doc = nil

        for_each_image_file(images,
                            origin_images) do |path, pg_size, pic_size, layout|
          if doc
            doc.start_new_page(size: pg_size, layout: layout)
          else
            doc = Prawn::Document.new(page_size: pg_size, page_layout: layout)
          end
          doc.image(path, position: :left, vposition: :top, fit: pic_size)
        end

        doc.render_file(pdf_path)
      end

      def pages_count(pdf_path)
        PDF::Reader.new(pdf_path).pages.count
      end

      def for_each_page(pdf_path)
        pages_count(pdf_path).times do |page_no|
          yield page_no
        end
      end

      private

      def for_each_image_file(images, origin_images)
        images.each_with_index do |picture, i|
          tempfile = Tempfile.new(['despeck', '.jpg'])
          pic = picture || origin_images[i]
          picture.write_to_file(tempfile.path)

          page_size = pdf_size(pic)
          layout = page_size.max == page_size.first ? :landscape : :portrait
          yield tempfile.path, page_size, pic.size, layout
        end
      end

      def pdf_size(image)
        image.size.map { |p| p + in2pt(1) }
      end
    end
  end
end
