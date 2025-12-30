/// Compile-time-safe translation keys. Use as `LocaleKeys.navHome.tr`.
///
/// Every key must exist in `en.dart`, `fr.dart` and `ar.dart`
/// (`test/translations_test.dart` enforces this).
abstract final class LocaleKeys {
  // Navigation & chrome
  static const navHome = 'nav_home';
  static const navSkills = 'nav_skills';
  static const navProjects = 'nav_projects';
  static const navContact = 'nav_contact';
  static const hireMe = 'hire_me';
  static const language = 'language';
  static const toggleTheme = 'toggle_theme';
  static const themeLight = 'theme_light';
  static const themeDark = 'theme_dark';
  static const themeSystem = 'theme_system';

  // Hero
  static const heroGreeting = 'hero_greeting';
  static const heroTitle = 'hero_title';
  static const heroSubtitle = 'hero_subtitle';
  static const heroBio = 'hero_bio';
  static const heroAvailable = 'hero_available';
  static const btnViewProjects = 'btn_view_projects';
  static const btnContactMe = 'btn_contact_me';
  static const btnDownloadCv = 'btn_download_cv';

  // Skills
  static const skillsEyebrow = 'skills_eyebrow';
  static const skillsTitle = 'skills_title';
  static const skillsSubtitle = 'skills_subtitle';
  static const skillCatCrossPlatform = 'skill_cat_cross_platform';
  static const skillCatCrossPlatformDesc = 'skill_cat_cross_platform_desc';
  static const skillCatNative = 'skill_cat_native';
  static const skillCatNativeDesc = 'skill_cat_native_desc';
  static const skillCatState = 'skill_cat_state';
  static const skillCatStateDesc = 'skill_cat_state_desc';
  static const skillCatBackend = 'skill_cat_backend';
  static const skillCatBackendDesc = 'skill_cat_backend_desc';
  static const skillCatTesting = 'skill_cat_testing';
  static const skillCatTestingDesc = 'skill_cat_testing_desc';
  static const skillCatCicd = 'skill_cat_cicd';
  static const skillCatCicdDesc = 'skill_cat_cicd_desc';

  // Projects
  static const projectsEyebrow = 'projects_eyebrow';
  static const projectsTitle = 'projects_title';
  static const projectsSubtitle = 'projects_subtitle';
  static const projectsEmpty = 'projects_empty';
  static const projectsError = 'projects_error';
  static const viewDetails = 'view_details';
  static const retry = 'retry';

  // Project detail
  static const detailBack = 'detail_back';
  static const detailOverview = 'detail_overview';
  static const detailProblem = 'detail_problem';
  static const detailArchitecture = 'detail_architecture';
  static const detailFeatures = 'detail_features';
  static const detailTechStack = 'detail_tech_stack';
  static const detailGallery = 'detail_gallery';
  static const detailLinks = 'detail_links';
  static const detailNoLinks = 'detail_no_links';
  static const detailRole = 'detail_role';
  static const detailYear = 'detail_year';
  static const detailPlatforms = 'detail_platforms';
  static const detailNotFound = 'detail_not_found';
  static const detailBackHome = 'detail_back_home';
  static const stackFrameworks = 'stack_frameworks';
  static const stackLibraries = 'stack_libraries';
  static const stackTools = 'stack_tools';
  static const linkPlayStore = 'link_play_store';
  static const linkAppStore = 'link_app_store';
  static const linkWebDemo = 'link_web_demo';
  static const linkGithub = 'link_github';
  static const galleryPrevious = 'gallery_previous';
  static const galleryNext = 'gallery_next';
  static const close = 'close';

  // Contact
  static const contactEyebrow = 'contact_eyebrow';
  static const contactTitle = 'contact_title';
  static const contactSubtitle = 'contact_subtitle';
  static const contactFindMe = 'contact_find_me';
  static const formName = 'form_name';
  static const formEmail = 'form_email';
  static const formMessage = 'form_message';
  static const formSend = 'form_send';
  static const errRequired = 'err_required';
  static const errEmail = 'err_email';
  static const errMessageShort = 'err_message_short';
  static const contactSuccessTitle = 'contact_success_title';
  static const contactSuccess = 'contact_success';
  static const contactSentTitle = 'contact_sent_title';
  static const contactSent = 'contact_sent';
  static const contactSendFailed = 'contact_send_failed';
  static const linkError = 'link_error';
  static const errorTitle = 'error_title';

  // Footer
  static const footerRights = 'footer_rights';
  static const footerBuiltWith = 'footer_built_with';

  // Hero stats (referenced from AppConfig.stats)
  static const heroStatYears = 'hero_stat_years';
  static const heroStatApps = 'hero_stat_apps';
  static const heroStatUsers = 'hero_stat_users';
}
