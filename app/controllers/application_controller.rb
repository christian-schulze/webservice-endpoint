class ApplicationController < ActionController::Base
  #protect_from_forgery

  def handle_request
    http_method = @_request.method
    folder_path = Rails.configuration.request_log_path
    filename = generate_filename(http_method, max_file_number(folder_path, http_method))
    full_path = File.join(folder_path, filename)
    File.open(full_path, 'w') do |file|
      file.write("#{http_method} #{@_request.fullpath}\n")
      file.write("\n======== Headers ========\n")
      file.write(serialize_headers)
      file.write("\n======== Body ========\n")
      file.write(@_request.body.read)
    end

    render :text => "ok"
  end

  private

  def serialize_headers
    filtered_headers = @_request.headers.find_all do |key, value|
      case
      when (key.start_with?("rack."))
        false
      when (key.start_with?("action_"))
        false
      else
        true
      end
    end
    filtered_headers.map { |key, value| "#{key}: #{value}\n" }.join
  end

  def generate_filename(http_method, number)
    http_method + "_" + number.to_s.rjust(2, '0') + ".txt"
  end

  def max_file_number(folder_path, filter)
    files = Dir.entries(folder_path).find_all { |file| file.start_with?(filter) }
    if files.size == 0
      0
    else
      files.sort! { |a,b| b <=> a }
      num = File.basename(files.first).split('_').last
      num.to_i + 1
    end
  end

end
