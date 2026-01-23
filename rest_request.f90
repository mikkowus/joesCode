program modern_fortran_rest
    use iso_c_binding
    implicit none

    ! --- 1. Define Interfaces to C functions (libcurl) ---
    interface
        ! curl_global_init(flags)
        function curl_global_init(flags) bind(C, name="curl_global_init")
            import
            integer(c_long), value :: flags
            integer(c_int) :: curl_global_init
        end function curl_global_init

        ! curl_easy_init()
        function curl_easy_init() bind(C, name="curl_easy_init")
            import
            type(c_ptr) :: curl_easy_init
        end function curl_easy_init

        ! curl_easy_setopt for setting the URL
        ! CHANGED: Renamed argument 'url' to 'c_string' to avoid masking parent variable
        function curl_easy_setopt_url(curl, option, c_string) bind(C, name="curl_easy_setopt")
            import
            type(c_ptr), value :: curl
            integer(c_int), value :: option
            character(kind=c_char), dimension(*), intent(in) :: c_string
            integer(c_int) :: curl_easy_setopt_url
        end function curl_easy_setopt_url

        ! curl_easy_perform(handle)
        function curl_easy_perform(curl) bind(C, name="curl_easy_perform")
            import
            type(c_ptr), value :: curl
            integer(c_int) :: curl_easy_perform
        end function curl_easy_perform

        ! curl_easy_cleanup(handle)
        subroutine curl_easy_cleanup(curl) bind(C, name="curl_easy_cleanup")
            import
            type(c_ptr), value :: curl
        end subroutine curl_easy_cleanup
    end interface

    ! --- 2. Constants and Variables ---
    integer(c_long), parameter :: CURL_GLOBAL_ALL = 3
    integer(c_int), parameter  :: CURLOPT_URL = 10002

    type(c_ptr) :: curl_handle
    integer(c_int) :: res
    character(len=100) :: url  ! This is the parent variable that was causing the conflict

    ! --- 3. Execution Logic ---
    print *, "Starting REST Request..."

    ! Initialize global curl environment
    res = curl_global_init(CURL_GLOBAL_ALL)

    ! Initialize the handle
    curl_handle = curl_easy_init()

    if (c_associated(curl_handle)) then
        ! Set the URL.
        ! IMPORTANT: We must append c_null_char to make it a valid C-string
        url = "https://isitreadonlyfriday.com/api/isitreadonlyfriday/est" // c_null_char

        ! Set the option (CURLOPT_URL)
        res = curl_easy_setopt_url(curl_handle, CURLOPT_URL, url)

        ! Perform the request
        print *, "Fetching data..."
        res = curl_easy_perform(curl_handle)

        ! Check for errors (0 = CURLE_OK)
        if (res /= 0) then
            print *, "Request failed with error code:", res
        else
            print *, "" ! Newline for clean output
            print *, "Request successful!"
        end if

        ! Cleanup
        call curl_easy_cleanup(curl_handle)
    else
        print *, "Failed to initialize curl."
    end if

end program modern_fortran_rest
