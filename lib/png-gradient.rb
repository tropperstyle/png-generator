require 'sinatra'
require 'RMagick'

module Png
  module Gradient
    class Generator < Sinatra::Base  
      get '/images/pngs/:dimensions/:gradient/:opacity' do    
        parse_params
        dimensions = @dimensions

        image = Magick::Image.read("gradient:#{@start_color}-#{@stop_color}") { self.size = dimensions }.first

        apply_opacity(image, @opacity)
        #cache_image(image, request.path)

        content_type 'image/png', :charset => 'utf-8'
        image.format = 'PNG'
        image.to_blob
      end

      get '/images/pngs/:dimensions/:gradient/:midpoint/:opacity' do
        parse_params
        width = @width
        gradient = Magick::Image.read("gradient:#{@start_color}-#{@stop_color}") { self.size = '1x3' }.first

        top_height = (@height * (params[:midpoint].to_i * 0.01)).ceil
        bottom_height = @height - top_height

        midpoint_color = gradient.view(0, 1, 1, 1)[0][0].to_color(Magick::AllCompliance, true, Magick::QuantumDepth, true)

        gradients = Magick::ImageList.new
        gradients << Magick::Image.read("gradient:#{@start_color}-#{midpoint_color}") { self.size = "#{width}x#{top_height}" }.first
        gradients << Magick::Image.read("gradient:#{midpoint_color}-#{@stop_color}") { self.size = "#{width}x#{bottom_height}" }.first

        image = gradients.append(true)

        apply_opacity(image, @opacity)
        #cache_image(image, request.path)

        content_type 'image/png', :charset => 'utf-8'
        image.format = 'PNG'
        image.to_blob
      end

      def parse_params
        @start_color, @stop_color = params[:gradient].split('-').map { |hex| "##{hex}" }
        @stop_color ||= @start_color
        @dimensions = params[:dimensions]
        @opacity = 1 - (params[:opacity].to_f / 100)
        @width, @height = @dimensions.split('x').map { |d| d.to_i }
      end

      def apply_opacity(image, opacity)
        image.alpha = Magick::ActivateAlphaChannel
        if opacity > 0
          image.rows.times do |row|
            pixels = image.get_pixels(0, row, image.columns, 1)
            pixels.each_with_index { |p,x|
              new_opacity = p.opacity + (opacity * Magick::TransparentOpacity) - (p.opacity * opacity)
              new_opacity = Magick::TransparentOpacity if new_opacity > Magick::TransparentOpacity
              p.opacity = new_opacity;
            }
            image.store_pixels(0, row, image.columns, 1, pixels)
          end
        end
      end

      def cache_image(image, path)
        path = "#{Rails.root}/public#{path}"
        FileUtils.mkdir_p(File.dirname(path))
        image.write(path)
      end
    end

  end
end
