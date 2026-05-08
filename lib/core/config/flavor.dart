enum Flavor { dev, prod }

class FlavorConfig {
  static Flavor _flavor = Flavor.dev;

  static void set(Flavor flavor) => _flavor = flavor;

  static Flavor get current => _flavor;
  static bool get isDev => _flavor == Flavor.dev;
  static bool get isProd => _flavor == Flavor.prod;
}
