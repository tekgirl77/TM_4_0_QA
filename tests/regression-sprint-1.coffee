describe '| regression-sprint-1 |', ->                                                                          # name of this suite of tests (should match the file name)
  page = require('./API/QA-TM_4_0_Design').create(before,after)                                             # required import and get page object
  jade = page.jade_API
  @timeout(7500)

  before (done)->
    jade.page_User_Logout ->
      done()

  it 'Issue 96 - Main Navigation "Login" link is not opening up the Login page', (done)->              # name of current test
    jade.page_Home (html,$)->                                                                               # open the index page
      login_Link = $('#nav-login')
      href       = login_Link.attr().href
      href.assert_Is_Not('/deploy/html/getting-started/index.html')                                         # checks that the link is the wrong one
      href.assert_Is    ('/guest/login.html')                                                               # checks that the link is not the 'correct' one
      done()

  it 'Issue 99 - Main Navigation "Sign Up" link is asking the user to login', (done)->
    jade.page_Home ->
      page.click 'SIGN UP', ->
        page.chrome.url (url_Via_Link)->
          jade.page_Sign_Up ->
          page.chrome.url (url_Link)->
            page.chrome.url (url_Direct)->
              url_Direct.assert_Is(url_Link)
              done()


  it 'Issue 102 - Password forgot is not sending requests to mapped TM instance', (done)->
    jade.page_Pwd_Forgot ->
      email = 'aaaaaa@securityinnovation.com' #qa-user@teammentor.net'
      page.chrome.eval_Script "document.querySelector('#email').value='#{email}';", =>
        page.chrome.eval_Script "document.querySelector('#btn-get-password').click();", =>
          page.wait_For_Complete  (html,$)->
            $('#heading p').html().assert_Is('Please log in to access TEAM Mentor.')
            $('#loginwall .alert #message' ).html().assert_Is("<span>If you entered a valid address, then a password reset link has been sent to your email address.</span>")
            done()

  it 'Issue 244 - Button type should be submit', (done)->
    jade.page_Pwd_Forgot (html, $) ->
      $('#heading p').html().assert_Is('Type in your email address and we&apos;ll send you an email with further instructions.')
      $('#btn-get-password').attr('type').assert_Is('submit')
      done()

  it 'Issue 117 - Getting Started Page is blank', (done)->
    jade.page_Home ->
      page.click 'START YOUR FREE TRIAL TODAY', (html, $)->
        $('#heading p').text().assert_Is('Gain access to the largest repository of secure software development knowledge.')
        jade.page_Home ->
          page.click 'SEE FOR YOURSELF', (html)->
            $('#heading p').text().assert_Is('Gain access to the largest repository of secure software development knowledge.')
            done()

  it 'Issue 118 - Clicking on TM logo while logged in should not bring back the main screen', (done)->
    jade.page_Home ->
      jade.login_As_QA (html,$)->

        $('#team-mentor-navigation a').attr().href.assert_Is('/user/main.html')
        done()

  #it 'Issue 119 - /returning-user-login.html is Blank', (done)->
  #  jade.page_Sign_Up_OK (html, $)->                                                       # open sign-up ok page
  #    $('p a').attr('href').assert_Is('/guest/login.html')                                 # confirm link is now ok
  #    page.chrome.eval_Script "document.documentElement.querySelector('p a').click()", ->  # click on link
  #      page.wait_For_Complete (html, $)->                                                 # wait for page to load
  #        $('h3').html().assert_Is("Login")                                                # confirm that we are on the login page
  #        done();

  xit 'Issue 120 - Recently Viewed Articles not working', (done)->
    jade.login_As_User ->
      article_Id    = 'aaaaaa_'.add_5_Letters()
      article_Title = 'bbbbbb_'.add_5_Letters()
      articleUrl = page.tm_Server + "/article/view/#{article_Id}/#{article_Title}"
      page.chrome.open articleUrl, ()->
        jade.page_User_Main (html, $)->
          using $('#recentlyViewedArticles a'),->
            @.attr().href.assert_Contains(article_Id)
            @.html().assert_Contains(article_Title)
            done()

  it 'Issue 123 - Terms and conditions link is available', (done)->
    jade.page_User_Logout (html,$)->
      footerDiv =  $('#terms-and-conditions').html()
      footerDiv.assert_Contains("Terms &amp; Conditions")
      done();

  it 'Issue 123 - Terms and conditions Page is displayed', (done)->
    jade.page_User_Logout (html,$)->
      footerDiv =  $('#terms-and-conditions').html()
      footerDiv.assert_Contains("Terms &amp; Conditions")
      page.click '#terms-and-conditions', (html,$)->
        $('#software-product-license-agreement').html().assert_Is("Software Product License Agreement")
        done();

  it 'Issue 124 - Forgot password page is blank', (done)->
    jade.page_Login ->
      page.click '#link-forgot-pwd', (html,$)->
        $('#heading p').text().assert_Is("Type in your email address and we'll send you an email with further instructions.")
        done();

  it 'Issue 128 - Opening /#{jade.url_Prefix}/{query} page with bad {query} should result in an "no results" page/view', (done)->
    jade.login_As_User ->
      page.open '/#{jade.url_Prefix}/aaaaaaa', (html)->
        page.html (html, $)->
          $('#containers a').length.assert_Is(0)
          done()

  it "Issue 129 - 'Need to login page' missing from current 'guest' pages", (done)->
    jade.keys().assert_Contains('page_Login_Required')
    page.open '/guest/login-required.html', (html,$)->
      $('#heading p').html().assert_Is('Please log in to access TEAM Mentor.')
      done()

  it 'Issue 151 - Add asserts for new Login page content ', (done)->
    jade.page_Login (html,$)->
      $('#btn-login').attr('type').assert_Is('submit')
      $('#btn-login').html().assert_Is('Login')
      $('#summary h2').html().assert_Is("Security Risk. Understood.")
      $('#summary h4').html().assert_Is("Instant resources that bridge the gap between developer questions and technical solutions.")
      $('#summary p').html().assert_Is("TEAM Mentor was created by developers for developers using secure coding standards, code snippets and checklists built from 10+ years of targeted security assessments for Fortune 500 organizations.")
      $('#summary h3').html().assert_Is("With TEAM Mentor, you can...")
      $($('.row p').get(2)).html().assert_Is("Fix vulnerabilities quicker than ever before.")
      $($('.row p').get(3)).html().assert_Is("Reduce the number of vulnerabilities over time.")
      $($('.row p').get(4)).html().assert_Is("Expand the development team&apos;s knowledge and improve process.")
      done()

  it 'Issue 173 - Add TM release version number to a specific location',(done)->
    jade.page_User_Logout ()->
      jade.page_About (html, $)->
        $("#footer h4").html().assert_Contains('TEAM Mentor v')
        done()

  #removed because the fix for https://github.com/TeamMentor/TM_4_0_Design/issues/164 removed the label value used below
  #it 'Issue 192 - When clicking on the TEXT of any filter, the top filter is selected',(done)->
  #  jade.login_As_User ->
  #    page.open '/graph/logging', ->
  #      # this code removes two rows so that only have the right-hand-side nav showing on page
  #      code = "children = document.documentElement.querySelector('.row').children;
  #              children[0].remove();
  #              children[0].remove();"
  #      page.chrome.eval_Script code, ->
  #        page.html (html,$)->
  #          for td in $('td')
  #            input = $(td).find('input')
  #            if (input.length)
  #              value = $(td).text()
  #              label = $(td).find('label')
  #              $(input).attr().id.assert_Is(value)
  #              label.attr().for.assert_Is(value)
  #          done()
#

  it 'Issue 195 - Wire the step down navigation', (done)->
    jade.login_As_User ->
      navigation = 'Technology,Phase,Type'
      page.open "/#{jade.url_Prefix}/#{navigation}", (html, $)->
        $('#navigation').html().assert_Contains ["/#{jade.url_Prefix}/Technology" , "/#{jade.url_Prefix}/Technology,Phase", "/#{jade.url_Prefix}/Technology,Phase,Type"]
        done()

  it 'Issue 196 - What should happen when an already logged in user returns to TM', (done)->
    jade.login_As_User ->
      jade.page_User_Main (html_user_main, $)->           # get html of user page after login
        page.open '/', (html_direct)->                    # get html of direct opening up / page (while logged in)
          html_direct.assert_Is html_user_main            # ensure they are the same
          jade.page_User_Logout ()->                      # logout user
            page.open '/', (html_after_logout)->          # get html of direct opening up / page (after logout)
              html_direct.assert_Is_Not html_after_logout # confirm it is not the same as logged in page
              page.chrome.url (url)->
                url.assert_Contains('/index.html')        # confirms redirect to 'index.html'
                done()

  it 'Issue 212 - Add page to render jade mixins directly', (done)->

    render = (file, mixin, viewModel, callback)->
      mixinPage = "/render/mixin/#{file}/#{mixin}?#{viewModel}"
      page.open mixinPage, (html, $)->
        callback($)

    no_Params = (next)->
      render 'user-mixins', 'login-form', "", ($)->
        $('form').attr().assert_Is({ id: 'login-form', role: 'form', method: 'post', action: '/user/login' })
        next();

    with_Params = (next)->
      render 'search-mixins', 'directory-list', "title=AAAA", ($)->
        $('h3').attr().id.assert_Is('title')
        next()

    with_Param_ViewModel_1 = (next)->
      render 'search-mixins', 'directory-list', 'viewModel={"title":"AAAA_123"}', ($)->
        $('h3').attr().id.assert_Is('title')
        next()

    with_Param_ViewModel_2 = (next)->
      viewModel = { recent_Articles :[ { id:'abc',title:'aaa'}, { id:'abc',title:'bbbb'}] }

      data = JSON.stringify(viewModel)
      render 'search-mixins', 'main-app-view', "viewModel=#{data}", ($)->
        $('#recently-Viewed-Articles a').attr().href.assert_Contains viewModel.recent_Articles.first().id
        next()

    no_Params ->
      with_Params ->
        with_Param_ViewModel_1 ->
          with_Param_ViewModel_2 ->
            done()

# commented due to https://github.com/TeamMentor/TM_4_0_Design/issues/456
#  it 'Issue 218 - Small alignment issue with Search button', (done)->
#    jade.login_As_User ->
#      jade.page_User_Main (html, $)->
#        juice   = require('juice')
#        cheerio = require('cheerio')
#        baseUrl = page.tm_Server;
#        juice.juiceContent html, { url: baseUrl}, (err, cssHtml)->
#          $css = cheerio.load(cssHtml)
#          attributes = $css('.input-group-btn').attr()
#          attributes.assert_Is { class: 'input-group-btn', style: 'display: table-cell; vertical-align: bottom;' }
#          done()

  xit 'Issue 298 - Search and Navigate page should only show top n articles',(done)->
    jade.login_As_User ->
      jade.page_User_Graph 'Technology', (html, $)->
        $('#articles a').length.assert_Bigger_Than 20
        done()

  it 'Issue 332 - When searching for ambiguous characthers ... fail the search gracefully', (done)->
    check_Search_Payload = (payload, next)->
      page.open "/search?text=#{payload}", (html,$)->
        $('form').attr().assert_Is { action: '/search', method: 'GET' }
        next()

    jade.login_As_User ()->
      check_Search_Payload '%00',->
        check_Search_Payload "a'b\"cdef'",->
          check_Search_Payload "a%27b%22c%3Cmarquee%3Edef",->
            check_Search_Payload '!@£$%^**()_+=-{}[]|":;\'\?><,./' ,->
              check_Search_Payload 'aaaa',->
                done()

  it 'Issue 380 - logout appears broken', (done)->
    jade.login_As_User ()->
      page.open '/user/main.html', (html,$)->
        $('#popular-Search-Terms h5').html().assert_Is 'Popular Search Terms'
        page.click 'LOGOUT', ->
          page.chrome.url (url)->
            url.assert_Contains '/guest/default.html'
            page.open '/user/main.html',(html,$)->
              $('#message').html().assert_Is '<span>You need to login to see that page.</span>'
              done()


  it 'Issue 328 - Add asserts for password complexity labels ', (done)->
    jade.page_Sign_Up (html,$)->
      $($('label').get(0)).html().assert_Is("Username")
      $($('.form-group p').get(0)).html().assert_Is("Your username should only contain letters and numbers.")
      $($('label').get(1)).html().assert_Is("Email Address")
      $($('.form-group p').get(1)).html().assert_Is("We&apos;ll email you a confirmation.")
      $($('label').get(2)).html().assert_Is("Password")
      $($('.form-group p').get(2)).html().assert_Is("Your password should be at least 8 characters long. It should have at least one of each of the following: uppercase and lowercase letters, number and special character.")
      $($('label').get(3)).html().assert_Is("Confirm Password")
      $($('p').get(4)).html().assert_Is("By signing up, you agree to our <a href=\"/misc/terms-and-conditions\">Terms and Conditions</a>.")
      done()

  it 'Issue 454 - Login/Signup options are displayed for logged in users (HTTP 500)', (done) ->
    jade.login_As_User ()->
      page.open '/article/%s', (html,$)->
        $('#an-error-occurred').html().assert_Is("An error occurred")
        $('p').html().assert_Is('If this continues, please contact your <a href=\"mailto:support@securityinnovation.com\">TEAM Mentor Support Team</a>.')
        #Logout should be availble
        $('ul').html().assert_Contains('Logout')
        jade.page_User_Logout ->
          done()

  it 'Issue 454 - Login/Signup options are displayed for logged in users (HTTP 400)', (done) ->
    jade.login_As_User ()->
      page.open '/articles/abc', (html,$)->
        $('#an-error-occurred').html().assert_Is("An error occurred")
        $('p').html().assert_Is('It&apos;s a HTTP 404 error - check the URL and refresh the browser.')
        #Logout should be availble
        $('ul').html().assert_Contains('Logout')
        jade.page_User_Logout ->
          done()

  it 'Issue 454- Login/Signup options are displayed for logged in users (HTTP 500 No logged In)', (done) ->
    page.open '/article/%s', (html,$)=>
      $('#an-error-occurred').html().assert_Is("An error occurred")
      $('p').html().assert_Is('If this continues, please contact your <a href=\"mailto:support@securityinnovation.com\">TEAM Mentor Support Team</a>.')
      #Testing that Sign Up and Login links are displayed
      $('ul').html().assert_Contains('Sign Up')
      $('ul').html().assert_Contains('Login')
      done()

  it 'Issue 454 - Login/Signup options are displayed for logged in users (HTTP 404 No logged In)', (done) ->
    page.open '/articles/abc', (html,$)=>
      $('#an-error-occurred').html().assert_Is("An error occurred")
      $('p').html().assert_Is('It&apos;s a HTTP 404 error - check the URL and refresh the browser.')
      #Testing that Sign Up and Login links are displayed
      $('ul').html().assert_Contains('Sign Up')
      $('ul').html().assert_Contains('Login')
      done()

  it 'Issue 440 - Check for no duplicates in Popular Search Terms', (done) ->
    @.timeout(12500)
    searchText = 'xss'
    validateSearch = (searchText, next)->
      page.open '/user/main.html', (html,$)->
        $('input').attr().assert_Is {"type":"text","id":"search-input","name":"text","class":"form-control"}
        code = "document.querySelector('input').value='#{searchText}';
                document.querySelector('button').click()"
        page.eval code, ->
          page.wait_For_Complete (html, $)->
            page.chrome.url (url)->
              url.assert_Contains '/search?text='+searchText
              $('input').attr('value').assert_Is searchText
              page.open '/user/main.html', (html,$)->
                $('input').attr().assert_Is {"type":"text","id":"search-input","name":"text","class":"form-control"}
                values = []
                for td in $('#popular-Search-Terms .nav td')
                  values.push($(td).text())
                values.assert_Is_Equal_To(values.unique())
                next()
    jade.login_As_User ()->
      validateSearch searchText, ->
        validateSearch searchText, ->
          validateSearch searchText, ->
            done()

  it 'Issue 492 - Validate right-hand side filter is working',(done)->
    jade.login_As_User ()->
      jade.page_User_Graph "", (html,$)->
        $('#activeFilter').text().assert_Is('')
        text = $($('#filters .filter-icon').get(2)).text()
        filterLink = $('#filters .nav a').eq(2).attr().href
        page.open filterLink, (html,$)->
          clearFilterLink = $('#activeFilter a')
          activeLinkText = $('#activeFilter').text().remove(clearFilterLink.text())
          activeLinkText.assert_Contains(text)
          done()

  it 'Issue 599 - Article Terms and Conditions link is broken', (done) ->
    jade.login_As_User ()->
      page.open '/article/4c396802c1d8/Missing-Function-Level-Access-Control', (html,$)->
        $('#terms-and-conditions').html().assert_Is("Terms &amp; Conditions")
        page.click '#terms-and-conditions', (html,$)->
          $('#software-product-license-agreement').html().assert_Is('Software Product License Agreement')
          page.chrome.url (url)->
            url.assert_Contains('misc/terms-and-conditions')
            done()

  it  'Issue 606 - Multiple Badges feature', (done) ->
    jade.login_As_User ()->
      page.open '/show/', (html,$)->
        log "Library: #{$('#title').text()}"
        selector_1 = $('.nav a span').eq(1).text()
        code = "document.querySelectorAll('.nav a span')[1].click();"
        page.chrome.eval_Script code, =>
          page.wait_For_Complete (html, $)=>
            code = "document.querySelectorAll('.nav a span')[1].click();"
            selector_2 = $('.nav a span').eq(1).text()
            page.chrome.eval_Script code, =>
              page.wait_For_Complete (html, $)=>
                badges = $('#activeFilter')
                badges[0].children[0].data.assert_Is(selector_1)
                badges[1].children[0].data.assert_Is(selector_2)
                done()

  it 'Issue 644 - Validate icon for each Technology or Type', (done)->
    mappings =  # mapping the technology or type to the icon title & class
      "Web Application" : { title : "Web Application" , class : "technology-icon web-app"     }
      "All"             : { title : "Any Technology"  , class : "fi-flag"                     }
      "C++"             : { title : "C++"             , class : "technology-icon c-plus-plus" }
      "iOS"             : { title : "iOS"             , class : "technology-icon ios"         }
      "Android"         : { title : "Android"         , class : "technology-icon android"     }
      ".NET 3.5"        : { title : "ASP.Net"         , class : "technology-icon asp"         }
      "Java"            : { title : "Java"            , class : "technology-icon java"        }
      ".NET"            : { title : "ASP.Net"         , class : "technology-icon asp"         }
      "Scala Play"      : { title : "Scala"           , class : "technology-icon scala"       }
      "PHP"             : { title : "PHP"             , class : "technology-icon php"         }
      "HTML5"           : { title : "HTML5"           , class : "fi-html5"                    }
      "Guideline"       : { title : "Guideline"       , class : "fi-book"                     }
      "Checklist Item"  : { title : "Checklist"       , class : "fi-checkbox"                 }
      "How To"          : { title : "How To"          , class : "fi-list-bullet"              }
      "Code Example"    : { title : "Code Sample"     , class : "fi-puzzle"                   }

    jade.login_As_User ()->
      jade.page_User_Index (html,$)->

        # span tag for filter-filter.title added in search-mixins.jade line #176
        technology = $('#filter-Technology')
        phase      = $('#filter-Phase')
        type       = $('#filter-Type')

        # Technology
        $(technology.find('h4')).html().assert_Is 'Technology'        # checking Technology values and icons

        technology.find('td').each (index, td)->                      # getting table data and index for each technology
          using $(td),->                                              # using table data
            text = $(@.find('span').eq(1)).html()                     # find each technology value from the 2nd span tag
            mappings[text].assert_Is_Object()                         # assert that technology name is listed in mappings
            if mappings[text].class.starts_With('fi')                 # take into account technology icon metadata within <i> tag rather than <div>
              $(@.find('i')).attr().assert_Is mappings[text]          # find and assert title & class attributes for the technology icon within <i> tag element
            else
              $(@.find('div')).attr().assert_Is mappings[text]        # else find and assert title & class attributes for the technology icon within the <div> tag element

        # Phase
        $(phase.find('h4')).html().assert_Is 'Phase'                # checking Phase value (no icons for phase)

        # Type
        $(type.find('h4')).html().assert_Is 'Type'                  # checking Type values and icons

        type.find('td').each (index, td)->                          # getting table data and index for each type
          using $(td),->                                            # using table data
            text = $(@.find('span').eq(1)).html()                   # find each type value from 2nd span tag
            mappings[text].assert_Is_Object()                       # assert that type name is listed in mappings
            $(@.find('i')).attr().assert_Is mappings[text]          # find and assert all type icon metadata within the first span <i> tag elements

        done()