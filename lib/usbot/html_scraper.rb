class HTMLScraper
  CONFIRMATION = 'AA00824VE4'
  AVAILABLE = "#9CCFFF"

  LOOK_MONTHS = 2
  MONDAY_INDEX = 1

  include Capybara::DSL

  def initialize
    Capybara.run_server = false
    Capybara.register_driver(:selenium) { |app| Capybara::Selenium::Driver.new(app, browser: :chrome) }
    Capybara.default_driver = :selenium
    Capybara.javascript_driver = :chrome
  end

  def scrap!
    page.visit('https://evisaforms.state.gov')

    country_select = page.find(:select, 'CountryCodeShow')

    belarus_option = country_select.find_all(:option).detect { |opt| opt['innerHTML'] =~ /BELARUS/ }
    belarus_option.select_option

    city_select = page.find(:select, 'PostCodeShow')

    minsk_option = city_select.find_all(:option).detect { |opt| opt['innerHTML'] =~ /MINSK/ }
    minsk_option.select_option

    page.click_button('Submit')
    page.click_button('link21')

    page.fill_in('link3b', with: CONFIRMATION)
    page.click_button('Submit')

    dates = {}

    LOOK_MONTHS.times do |month_index|
      switch_month(month_index)

      month_select = page.find(:select, 'nDate')
      current_month = month_select.find_all(:option)[month_index]
      month_text = current_month.text

      page.find_all('td.formfield').each do |td|
        if (color = td['bgcolor']&.upcase) && color == AVAILABLE
          links = td.find_all('a')
          date = build_date(month_text, links[0])
          dates[date] = links[1].text
        end
      end
    end

    page.driver.quit

    dates
  end

  private

  def switch_month(index)
    page.find(:select, 'nDate').find_all(:option)[index].select_option
  end

  def build_date(date, month)
    Date.parse("#{grab_month(month)} #{date}".gsub(/\s+/, ' '))
  end

  def grab_month(node)
    node.text.match(/\A(\d+)/)[0]
  end
end
