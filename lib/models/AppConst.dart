
class AppConst{

  static final String domain = "https://tcgapi.com/";
  static final String baseUrl = domain+"api/";
  static final String searchYGOCard = baseUrl+"search-ygo-card-name";
  static final String getYGOCardNames = baseUrl+"get-ygo-card-names";

  static final String searchPMCard = baseUrl+"search-pm-card-name";
  static final String getPMCardNames = baseUrl+"get-pm-card-names";

  static final String searchMGCard = baseUrl+"search-mg-card-name";
  static final String getMGCardNames = baseUrl+"get-mg-card-names";

  static final String addClickHistory = baseUrl+"add-click-history";
}

String appCurrency = "CAD";
bool isLowestPrice = true;
bool buyMode = true;

enum CardType{
  ygo,
  pokemon,
  magic
}