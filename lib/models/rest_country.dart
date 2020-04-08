class RestCountry {
  String name;
  String alpha2Code;
  String alpha3Code;
  String region;
  String subRegion;
  int population;
  List<double> latLong;
  String flagUrl;

  RestCountry(this.name, this.alpha2Code, this.alpha3Code, this.region,
      this.subRegion, this.population, this.latLong, this.flagUrl);

  factory RestCountry.fromMap(Map data) {
    return RestCountry(
      data['name'],
      data['alpha2Code'],
      data['alpha3Code'],
      data['region'],
      data['subRegion'],
      data['population'],
      data['latLong'],
      data['flagUrl'],
    );
  }
}
