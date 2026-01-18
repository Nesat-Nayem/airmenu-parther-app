
import 'package:airmenuai_partner_app/config/environment/env_config.dart';

class Env {
  final String string;

  const Env._(this.string);

  static const dev = Env._("dev");
  static const test = Env._("test");
  static const accp = Env._("accp");
  static const prod = Env._("prod");

  static Env current({String config = EnvConfig.env}) {
    config = config.toLowerCase();

    switch (config) {
      case 'dev':
        return Env.dev;
      case 'test':
        return Env.test;
      case 'accp':
        return Env.accp;
      case 'prod':
        return Env.prod;


    }

    return Env.dev;
  }

 }
