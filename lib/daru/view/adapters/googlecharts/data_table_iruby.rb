require 'securerandom'
require 'google_visualr'

module GoogleVisualr
  class DataTable
    # options will enable us to give some styling for table.
    # E.g. pagination, row numbers, etc
    attr_accessor :options

    # included to use `js_parameters` method
    include GoogleVisualr::ParamHelpers

    # overiding the current initialze method (of the google_visualr).
    # This might be not a good idea. But right now I need these lines in it :
    # ` unless options[:cols].nil?` , `unless options[:rows].nil?` and
    # `@options = options`
    # Few lines is changed, to fix rubocop error.
    def initialize(options={})
      @cols = []
      @rows = []
      @options = options
      return if options.empty?

      new_columns(options[:cols]) unless options[:cols].nil?

      return if options[:rows].nil?
      rows = options[:rows]
      rows.each do |row|
        add_row(row[:c])
      end
    end

    # Generates JavaScript and renders the Google Chart DataTable in the
    # final HTML output.
    #
    # Parameters:
    #  *div_id            [Required] The ID of the DIV element that the Google
    #                       Chart DataTable should be rendered in.
    def to_js_full_script(element_id=SecureRandom.uuid)
      js =  ''
      js << '\n<script type=\'text/javascript\'>'
      js << load_js(element_id)
      js << draw_js(element_id)
      js << '\n</script>'
      js
    end

    # Generates JavaScript and renders the Google Chart DataTable in the
    # final HTML output.
    #
    # Parameters:
    #  *div_id            [Required] The ID of the DIV element that the Google
    #                       Chart DataTable should be rendered in.
    def to_js_full_script_spreadsheet(data, element_id=SecureRandom.uuid)
      js =  ''
      js << '\n<script type=\'text/javascript\'>'
      js << load_js(element_id)
      js << draw_js_spreadsheet(data, element_id)
      js << '\n</script>'
      js
    end

    def chart_function_name(element_id)
      "draw_#{element_id.tr('-', '_')}"
    end

    def google_table_version
      '1.0'.freeze
    end

    def package_name
      'table'
    end

    # Generates JavaScript for loading the appropriate Google Visualization
    #   package, with callback to render chart.
    #
    # Parameters:
    #  *data              [Required] The URL of the spreadsheet in a specified
    #                       format. Query string can be appended to retrieve the
    #                       data accordingly.
    #  *div_id            [Required] The ID of the DIV element that the Google
    #                       Chart should be rendered in.
    def load_js(element_id)
      js = ''
      js << "\n  google.load('visualization', #{google_table_version}, "
      js << "\n {packages: ['#{package_name}'], callback:"
      js << "\n #{chart_function_name(element_id)}});"
      js
    end

    # Generates JavaScript function for rendering the chart.
    #
    # Parameters:
    #  *div_id            [Required] The ID of the DIV element that the Google
    #                       Chart should be rendered in.
    def draw_js(element_id)
      js = ''
      js << "\n  function #{chart_function_name(element_id)}() {"
      js << "\n    #{to_js}"
      js << "\n    var table = new google.visualization.Table("
      js << "\n    document.getElementById('#{element_id}'));"
      js << "\n    table.draw(data_table, #{js_parameters(@options)}); "
      js << "\n  };"
      js
    end

    # Generates JavaScript function for rendering the chart.
    #
    # Parameters:
    #  *data              [Required] The URL of the spreadsheet in a specified
    #                       format. Query string can be appended to retrieve the
    #                       data accordingly.
    #  *div_id            [Required] The ID of the DIV element that the Google
    #                       Chart should be rendered in.
    def draw_js_spreadsheet(data, element_id)
      js = ''
      js << "\n  function #{chart_function_name(element_id)}() {"
      js << "\n  var query = new google.visualization.Query('#{data}');"
      js << "\n  query.send(handleQueryResponse);"
      js << "\n  }"
      js << "\n  function handleQueryResponse(response) {"
      js << "\n  var data_table = response.getDataTable();"
      js << "\n  var table = new google.visualization.Table"\
            "(document.getElementById('#{element_id}'));"
      js << "\n  table.draw(data_table, #{js_parameters(@options)});"
      js << "\n  };"
      js
    end
  end
end
