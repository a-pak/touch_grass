// TODO: päivittäisen haasteen datan esitysmuoto
// alla esimerkki; ei välttämättä pakollinen mutta turvallisempaa koodia
// date ja scientificname mahdollisesti ainakin pois

class DailyChallenge {
  final String targetPlantName;
  final String targetScientificName;
  final DateTime date;
  final bool isCompleted;

  const DailyChallenge({
    required this.targetPlantName,
    required this.targetScientificName,
    required this.date,
    required this.isCompleted,
  });
}