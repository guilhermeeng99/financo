// ignore_for_file: avoid_field_initializers_in_const_classes, subtype_of_disallowed_type

AppRoutes get ro => AppRoutes.instance;

class AppRoutes {
  const AppRoutes._();

  static const AppRoutes instance = AppRoutes._();

  final AppRoutesLoading loading = const AppRoutesLoading();
  final AppRoutesLogin login = const AppRoutesLogin();
  final AppRoutesMainFlow mainFlow = const AppRoutesMainFlow();
}

class AppRoutesLoading {
  const AppRoutesLoading();

  final String route = '/loading/';
}

class AppRoutesLogin {
  const AppRoutesLogin();

  final String route = '/login/';
}

class AppRoutesMainFlow {
  const AppRoutesMainFlow();

  final String route = '/main_flow/';
  final AppRoutesMainFlowAiTab aiTab = const AppRoutesMainFlowAiTab();
  final AppRoutesMainFlowFishingTab fishingTab = const AppRoutesMainFlowFishingTab();
  final AppRoutesMainFlowFriendsTab friendsTab = const AppRoutesMainFlowFriendsTab();
  final AppRoutesMainFlowProfileTab profileTab = const AppRoutesMainFlowProfileTab();
  final AppRoutesMainFlowQuestTab questTab = const AppRoutesMainFlowQuestTab();
  final AppRoutesMainFlowSettings settings = const AppRoutesMainFlowSettings();
  final AppRoutesMainFlowShop shop = const AppRoutesMainFlowShop();
}

class AppRoutesMainFlowAiTab {
  const AppRoutesMainFlowAiTab();

  final String route = '/main_flow/ai_tab/';
  final AppRoutesMainFlowAiTabGoalsAiTab goalsAiTab = const AppRoutesMainFlowAiTabGoalsAiTab();
  final AppRoutesMainFlowAiTabJournalAiTab journalAiTab = const AppRoutesMainFlowAiTabJournalAiTab();
  final AppRoutesMainFlowAiTabMoodAiTab moodAiTab = const AppRoutesMainFlowAiTabMoodAiTab();
}

class AppRoutesMainFlowAiTabGoalsAiTab {
  const AppRoutesMainFlowAiTabGoalsAiTab();

  final String route = '/main_flow/ai_tab/goals_ai_tab/';
}

class AppRoutesMainFlowAiTabJournalAiTab {
  const AppRoutesMainFlowAiTabJournalAiTab();

  final String route = '/main_flow/ai_tab/journal_ai_tab/';
  final String analyzingEntry = '/main_flow/ai_tab/journal_ai_tab/analyzing_entry/';
  final String record = '/main_flow/ai_tab/journal_ai_tab/record/';
  final String typePrompt = '/main_flow/ai_tab/journal_ai_tab/type_prompt/';
  final AppRoutesMainFlowAiTabJournalAiTabEntriesHistory entriesHistory = const AppRoutesMainFlowAiTabJournalAiTabEntriesHistory();
  final AppRoutesMainFlowAiTabJournalAiTabResultAndEdit resultAndEdit = const AppRoutesMainFlowAiTabJournalAiTabResultAndEdit();
}

class AppRoutesMainFlowAiTabJournalAiTabEntriesHistory {
  const AppRoutesMainFlowAiTabJournalAiTabEntriesHistory();

  final String route = '/main_flow/ai_tab/journal_ai_tab/entries_history/';
  final AppRoutesMainFlowAiTabJournalAiTabEntriesHistoryEntriesCalendar entriesCalendar =
      const AppRoutesMainFlowAiTabJournalAiTabEntriesHistoryEntriesCalendar();
}

class AppRoutesMainFlowAiTabJournalAiTabEntriesHistoryEntriesCalendar {
  const AppRoutesMainFlowAiTabJournalAiTabEntriesHistoryEntriesCalendar();

  final String route = '/main_flow/ai_tab/journal_ai_tab/entries_history/entries_calendar/';
  final AppRoutesMainFlowAiTabJournalAiTabEntriesHistoryEntriesCalendarOpenCalendarEntry openCalendarEntry =
      const AppRoutesMainFlowAiTabJournalAiTabEntriesHistoryEntriesCalendarOpenCalendarEntry();
}

class AppRoutesMainFlowAiTabJournalAiTabEntriesHistoryEntriesCalendarOpenCalendarEntry {
  const AppRoutesMainFlowAiTabJournalAiTabEntriesHistoryEntriesCalendarOpenCalendarEntry();

  final String route = '/main_flow/ai_tab/journal_ai_tab/entries_history/entries_calendar/open_calendar_entry/';
}

class AppRoutesMainFlowAiTabJournalAiTabResultAndEdit {
  const AppRoutesMainFlowAiTabJournalAiTabResultAndEdit();

  final String route = '/main_flow/ai_tab/journal_ai_tab/result_and_edit/';
  final AppRoutesMainFlowAiTabJournalAiTabResultAndEditResultCapyMessage resultCapyMessage =
      const AppRoutesMainFlowAiTabJournalAiTabResultAndEditResultCapyMessage();
  final AppRoutesMainFlowAiTabJournalAiTabResultAndEditUnsavedResultChanges unsavedResultChanges =
      const AppRoutesMainFlowAiTabJournalAiTabResultAndEditUnsavedResultChanges();
}

class AppRoutesMainFlowAiTabJournalAiTabResultAndEditResultCapyMessage {
  const AppRoutesMainFlowAiTabJournalAiTabResultAndEditResultCapyMessage();

  final String route = '/main_flow/ai_tab/journal_ai_tab/result_and_edit/result_capy_message/';
}

class AppRoutesMainFlowAiTabJournalAiTabResultAndEditUnsavedResultChanges {
  const AppRoutesMainFlowAiTabJournalAiTabResultAndEditUnsavedResultChanges();

  final String route = '/main_flow/ai_tab/journal_ai_tab/result_and_edit/unsaved_result_changes/';
}

class AppRoutesMainFlowAiTabMoodAiTab {
  const AppRoutesMainFlowAiTabMoodAiTab();

  final String route = '/main_flow/ai_tab/mood_ai_tab/';
}

class AppRoutesMainFlowFishingTab {
  const AppRoutesMainFlowFishingTab();

  final String route = '/main_flow/fishing_tab/';
  final AppRoutesMainFlowFishingTabOpenHabit openHabit = const AppRoutesMainFlowFishingTabOpenHabit();
}

class AppRoutesMainFlowFishingTabOpenHabit {
  const AppRoutesMainFlowFishingTabOpenHabit();

  final String route = '/main_flow/fishing_tab/open_habit/';
  final AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabit createAndEditHabit = const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabit();
}

class AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabit {
  const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabit();

  final String route = '/main_flow/fishing_tab/open_habit/create_and_edit_habit/';
  final AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitDate date = const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitDate();
  final AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitIcon icon = const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitIcon();
  final AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitRecurrence recurrence =
      const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitRecurrence();
  final AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitReminder reminder =
      const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitReminder();
  final AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTag tag = const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTag();
  final AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTime time = const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTime();
  final AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitUnsavedHabitChanges unsavedHabitChanges =
      const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitUnsavedHabitChanges();
}

class AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitDate {
  const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitDate();

  final String route = '/main_flow/fishing_tab/open_habit/create_and_edit_habit/date/';
}

class AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitIcon {
  const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitIcon();

  final String route = '/main_flow/fishing_tab/open_habit/create_and_edit_habit/icon/';
}

class AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitRecurrence {
  const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitRecurrence();

  final String route = '/main_flow/fishing_tab/open_habit/create_and_edit_habit/recurrence/';
}

class AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitReminder {
  const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitReminder();

  final String route = '/main_flow/fishing_tab/open_habit/create_and_edit_habit/reminder/';
}

class AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTag {
  const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTag();

  final String route = '/main_flow/fishing_tab/open_habit/create_and_edit_habit/tag/';
  final AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTagDeleteTag deleteTag =
      const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTagDeleteTag();
}

class AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTagDeleteTag {
  const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTagDeleteTag();

  final String route = '/main_flow/fishing_tab/open_habit/create_and_edit_habit/tag/delete_tag/';
}

class AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTime {
  const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitTime();

  final String route = '/main_flow/fishing_tab/open_habit/create_and_edit_habit/time/';
}

class AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitUnsavedHabitChanges {
  const AppRoutesMainFlowFishingTabOpenHabitCreateAndEditHabitUnsavedHabitChanges();

  final String route = '/main_flow/fishing_tab/open_habit/create_and_edit_habit/unsaved_habit_changes/';
}

class AppRoutesMainFlowFriendsTab {
  const AppRoutesMainFlowFriendsTab();

  final String route = '/main_flow/friends_tab/';
}

class AppRoutesMainFlowProfileTab {
  const AppRoutesMainFlowProfileTab();

  final String route = '/main_flow/profile_tab/';
  final AppRoutesMainFlowProfileTabCapyItems capyItems = const AppRoutesMainFlowProfileTabCapyItems();
}

class AppRoutesMainFlowProfileTabCapyItems {
  const AppRoutesMainFlowProfileTabCapyItems();

  final String route = '/main_flow/profile_tab/capy_items/';
}

class AppRoutesMainFlowQuestTab {
  const AppRoutesMainFlowQuestTab();

  final String route = '/main_flow/quest_tab/';
}

class AppRoutesMainFlowSettings {
  const AppRoutesMainFlowSettings();

  final String route = '/main_flow/settings/';
  final AppRoutesMainFlowSettingsNotifications notifications = const AppRoutesMainFlowSettingsNotifications();
  final AppRoutesMainFlowSettingsProfile profile = const AppRoutesMainFlowSettingsProfile();
  final AppRoutesMainFlowSettingsRoutine routine = const AppRoutesMainFlowSettingsRoutine();
}

class AppRoutesMainFlowSettingsNotifications {
  const AppRoutesMainFlowSettingsNotifications();

  final String route = '/main_flow/settings/notifications/';
}

class AppRoutesMainFlowSettingsProfile {
  const AppRoutesMainFlowSettingsProfile();

  final String route = '/main_flow/settings/profile/';
  final AppRoutesMainFlowSettingsProfileEditName editName = const AppRoutesMainFlowSettingsProfileEditName();
}

class AppRoutesMainFlowSettingsProfileEditName {
  const AppRoutesMainFlowSettingsProfileEditName();

  final String route = '/main_flow/settings/profile/edit_name/';
}

class AppRoutesMainFlowSettingsRoutine {
  const AppRoutesMainFlowSettingsRoutine();

  final String route = '/main_flow/settings/routine/';
}

class AppRoutesMainFlowShop {
  const AppRoutesMainFlowShop();

  final String route = '/main_flow/shop/';
}
