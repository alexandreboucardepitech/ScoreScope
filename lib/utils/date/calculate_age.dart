import 'package:age_calculator/age_calculator.dart';

int calculateAge(DateTime dateNaissance) {
  DateDuration age = AgeCalculator.age(dateNaissance);
  return age.years;
}