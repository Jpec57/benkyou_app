import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

const JAP_LOCALE = 'ja';
const EN_LOCALE = 'en';
const FR_LOCALE = 'fr';

const SUPPORTED_LOCALES = [EN_LOCALE, FR_LOCALE, JAP_LOCALE];

class LocalizationWidget {
  LocalizationWidget(this.locale);

  final Locale locale;

  static LocalizationWidget of(BuildContext context) {
    return Localizations.of<LocalizationWidget>(context, LocalizationWidget);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    EN_LOCALE: {
      'home': 'Home',
      'result': 'Result',
      'choose_picture': 'Choose a picture and select a text area',
      'take_photo': 'Take a photo',
      'take_gallery': 'Take from gallery',
      'gap_sentences': 'Gap sentences',
      'grammar_card_explanation':
          'A grammar card consists of a grammar point and gap fill sentences including this grammar point. To help memorizing, the grammar you will be asked to fill the gap. ',
      'extract_text': 'Extract text from picture',
      'loading': 'Loading...',
      'no_photo': 'No photo. Please select one.',
      'next': 'Next',
      'extract': 'Extract text',
      'extract_sentence': 'Extract sentence',
      'organize_extracted_text': 'Organize extracted text',
      'no_extracted_text': 'No extracted text',
      'search_term_grammar':
          'Enter something as grammar point name to look for example sentences.',
      'remaining': 'Remaining',
      'translate': 'Translate',
      'review_all_decks': 'Review all decks',
      'translate_in_japanese': 'Translate in japanese',
      'quit_session': 'Quit current session ?',
      'kanji': 'Kanji',
      'experience': 'Experience',
      'create_account': 'Create account',
      'username': 'Username',
      'enter_username': 'Please enter your username',
      'email': 'Email',
      'check': 'Check',
      'themes': 'Themes',
      'vocabulary': 'Vocabulary',
      'submitting': 'Submitting...',
      'theme_vocab': 'Theme vocabulary',
      'upload_deck_background': 'Upload deck background',
      'enter_email': 'Please enter your email',
      'password': 'Password',
      'enter_password': 'Please enter your password',
      'at_least_6_char': 'Your password must use at least 6 characters',
      'confirm_password': "Confirm password",
      'enter_confirm_password': 'Please confirm your password',
      'password_not_match': "Passwords don't match",
      'enter_pass_again': 'Enter your password again',
      'register': 'Register',
      'delete_deck': 'Delete deck',
      'edit_deck': 'Edit deck',
      'synonyms': 'Synonyms',
      'synonym_info':
          'You can enter here all the answers that will be counted as accepted to fill the gap sentences',
      'gap_sentences_info':
          'Surround with curly braces the part you want later to fill. Usually, it matches the grammar point name content.',
      'update_deck': 'Update deck',
      'create_deck': 'Create deck',
      'create_a_deck': 'Create a deck',
      'confirm_delete_deck_mess': "Are you sure you want to delete this deck ?",
      'enter_description': 'Enter a description',
      'description': "Description",
      'title': 'Title',
      'my_grammar_cards': 'My grammar cards',
      'my_word_cards': 'My word cards',
      'delete_card': 'Delete card',
      'enter_title': 'Enter a title',
      'min_2_title': 'Your title must use at least 2 characters.',
      'action_to_create_deck': 'to create a deck.',
      'add_deck': 'Add a deck',
      'preview_deck': 'Preview deck',
      'empty_deck_create_card': "The deck is empty. Please create a card.",
      'card_explanation':
          "A card is a unknown word you encounter while reading that you want to remember. "
              "By simply entering the word, the Jisho API will translate it for you. "
              "You will be able to resume reading and this word will come back later in review"
              " to make sure that you will progressively remember it.",
      'what_did_hear': 'What did you hear ?',
      'empty_deck': 'Empty deck',
      'empty_deck_publish_error':
          'Your deck must have at least one card to be published.',
      'start': 'Start',
      'stop': 'Stop',
      'draw': 'Draw',
      'lessons': 'Lessons',
      'my_lessons': 'My lessons',
      'start_conv': 'Start conversation',
      'listening': 'Listening',
      'reading': 'Reading',
      'dialog': 'Dialog',
      'dialogs': 'Dialogs',
      'wrong_translation': 'Wrong translation... It should be: ',
      'empty': 'Empty',
      'word_to_translate': 'Japanese word to translate',
      'review_decks': 'Review decks',
      'speak': 'Speak',
      'all_reviews': 'All reviews',
      'field_empty': 'Field cannot be left empty',
      'fields_empty': 'Fields cannot be left empty',
      'enter_search_word': 'Enter a word to search',
      'my_cards': 'My cards',
      'no_card_create_one': 'There is no card. Please create one.',
      'modify_card': 'Modify card',
      'delete': 'Delete',
      'update': 'Update',
      'by': 'by',
      'list_cards_in_deck': 'List of cards in deck',
      'import_own_deck_error': 'You cannot import your own deck...',
      'error': 'Error',
      'import_deck': "Import this deck",
      'no_data': "No data.",
      'stop_review': 'Stop review',
      'quit_review_before_end_mess':
          "Do you want to leave the review ? Your progression will be saved.",
      'save': 'Save',
      'no': "No",
      'yes': 'Yes',
      'add_note': 'Add a note',
      'add_answer': 'Add answer',
      'add_edit_text': 'Add/ Edit text',
      'edit_note': 'Edit note',
      'possible_answers': 'Possible answers',
      'users_note': "User's note",
      'review': 'Review',
      'english': 'English',
      'japanese': 'Japanese',
      'answer': 'Answer',
      'possible_answer': 'Possible answer',
      'confirm_action': 'Confirm action',
      'must_be_connected_message': 'You must be connected.',
      'login': 'Login',
      'login_or_register': 'Login or register',
      'no_card_yet': 'There is no card yet.',
      'no_connection': 'No connection',
      'searching': 'Searching...',
      'kana_kanji_start_search':
          "Please enter a kana or a kanji to start searching.",
      'not_member_yet': "Not a member yet ? Register here",
      'welcome_back': 'Welcome back',
      'generic_error':
          'An error occurred. Please contact the support for any help.',
      'user_email': "Username / email",
      'enter_username_email': 'Please enter your username or email',
      'log_out': 'Log out',
      'log_in': 'Log in',
      'my_decks': 'My decks',
      'my_word_decks': 'My word decks',
      'browse_online_decks': 'Browse online decks',
      'cancel': 'Cancel',
      'unpublish': 'Unpublish',
      'publish': 'Publish',
      'like_lesson_or not': 'Show your love',
      'modify_text': 'Modify text',
      'enter_something_here': 'Enter something here',
      'my_profile': 'My profile',
      'unpublish_your_deck': 'Unpublish your deck',
      'publish_your_deck': 'Publish your deck',
      'confirm_private_deck':
          "Are you sure you want to make you deck private again ? All copies already done by users will not be deleted.",
      'confirm_publish_deck':
          "Publishing your deck means that anybody will be able to see your deck in the 'Browse' section. Do you want to continue ?",
      'kana_kanji_tranform': 'Kana/Romaji to transform',
      'enter_kana_kanji': 'Enter kana or romaji here',
      'input_kanji_label': 'Enter kanji here',
      'is_card_reversible': 'Is card reversible ?',
      'card_inverse_explanation':
          'Another card inverting japanese and english will be created',
      'prop_of_answer': 'Propositions of answer',
      'browse_online_deck': 'Browse Online Deck',
      'no_deck_create': 'No deck available. Please create one.',
      'powered_by_jisho': 'powered by Jisho',
      'no_internet_connection':
          'Internet connection issue: please refresh again later.',
      'create_card': 'Create a card',
      'info': 'Info',
      'close': 'Close',
      'following': 'Following',
      'followers': 'Followers',
      'likes': 'Likes',
      'deck_info_1':
          'When using Benkyou, you have to organize your review in decks. By this way, you will create a learning unit.',
      'deck_info_2':
          'For instance, if you read a lot of Pokemon manga, it could be interesting to create a deck named "Pokemon" or even "Pokemon Tome 1" since the vocabulary can quickly pile up...',
      'deck_info_3':
          'Later, you can even decide to share it with the community (or not) !',
      'grammar': 'Grammar',
      'list_dialogs': 'List of dialogs',
      'my_grammar_decks': 'My grammar decks',
      'create_grammar_card': 'Create a grammar card',
      'create_vocab_card': 'Create a vocabulary card',
      'create_another_card': 'Create another card',
      'create_card_success': 'Your card have been successfully created !',
    },
    FR_LOCALE: {'home': 'Accueil', 'browse_online_deck': 'Parcourir les decks'},
    JAP_LOCALE: {
      'home': 'ie',
    },
  };

  String getLocalizeValue(String key) {
    if (!_localizedValues[locale.languageCode].containsKey(key)) {
      if (!_localizedValues[EN_LOCALE].containsKey(key)) {
        return key;
      }
      return _localizedValues[EN_LOCALE][key];
    }
    return _localizedValues[locale.languageCode][key];
  }
}

class MyLocalizationsDelegate
    extends LocalizationsDelegate<LocalizationWidget> {
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      SUPPORTED_LOCALES.contains(locale.languageCode);

  @override
  Future<LocalizationWidget> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<LocalizationWidget>(LocalizationWidget(locale));
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
