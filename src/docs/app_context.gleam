import docs/page_server.{type PageServer}
import docs/utils/csrf.{type CSRFValidator}

pub type AppContext {
  AppContext(
    secret_key_base: String,
    validate_csrf: CSRFValidator,
    page_server: PageServer,
  )
}
