// To parse this JSON data, do
//
//     final foodModel = foodModelFromJson(jsonString);

import 'dart:convert';

FoodModel foodModelFromJson(String str) => FoodModel.fromJson(json.decode(str));

String foodModelToJson(FoodModel data) => json.encode(data.toJson());

class FoodModel {
  List<Meal>? meals;

  FoodModel({
    this.meals,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) => FoodModel(
        meals: json["meals"] == null
            ? []
            : List<Meal>.from(json["meals"]!.map((x) => Meal.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "meals": meals == null
            ? []
            : List<dynamic>.from(meals!.map((x) => x.toJson())),
      };
}

class Meal {
  String? idMeal;
  String? strMeal;
  String? strCategory;
  String? strArea;
  String? strInstructions;
  String? strTags;
  String? strYoutube;
  String? strIngredient1;
  String? strMeasure1;
  String? strMealThumb;
  String? strIngredient2;
  String? strMeasure2;
  String? strIngredient3;
  String? strMeasure3;
  String? strIngredient4;
  String? strMeasure4;
  String? strIngredient5;
  String? strMeasure5;
  String? strIngredient6;
  String? strMeasure6;
  String? strSource;
  dynamic strImageSource;
  dynamic strCreativeCommonsConfirmed;
  dynamic dateModified;

  Meal({
    this.idMeal,
    this.strMeal,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strTags,
    this.strYoutube,
    this.strIngredient1,
    this.strMeasure1,
    this.strMealThumb,
    this.strIngredient2,
    this.strMeasure2,
    this.strIngredient3,
    this.strMeasure3,
    this.strIngredient4,
    this.strMeasure4,
    this.strIngredient5,
    this.strMeasure5,
    this.strIngredient6,
    this.strMeasure6,
    this.strSource,
    this.strImageSource,
    this.strCreativeCommonsConfirmed,
    this.dateModified,
  });

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        idMeal: json["idMeal"],
        strMeal: json["strMeal"],
        strCategory: json["strCategory"],
        strArea: json["strArea"],
        strInstructions: json["strInstructions"],
        strTags: json["strTags"],
        strYoutube: json["strYoutube"],
        strIngredient1: json["strIngredient1"],
        strMeasure1: json["strMeasure1"],
        strMealThumb: json["strMealThumb"],
        strIngredient2: json["strIngredient2"],
        strMeasure2: json["strMeasure2"],
        strIngredient3: json["strIngredient3"],
        strMeasure3: json["strMeasure3"],
        strIngredient4: json["strIngredient4"],
        strMeasure4: json["strMeasure4"],
        strIngredient5: json["strIngredient5"],
        strMeasure5: json["strMeasure5"],
        strIngredient6: json["strIngredient6"],
        strMeasure6: json["strMeasure6"],
        strSource: json["strSource"],
        strImageSource: json["strImageSource"],
        strCreativeCommonsConfirmed: json["strCreativeCommonsConfirmed"],
        dateModified: json["dateModified"],
      );

  Map<String, dynamic> toJson() => {
        "idMeal": idMeal,
        "strMeal": strMeal,
        "strCategory": strCategory,
        "strArea": strArea,
        "strInstructions": strInstructions,
        "strTags": strTags,
        "strYoutube": strYoutube,
        "strIngredient1": strIngredient1,
        "strMeasure1": strMeasure1,
        "strMealThumb": strMealThumb,
        "strIngredient2": strIngredient2,
        "strMeasure2": strMeasure2,
        "strIngredient3": strIngredient3,
        "strMeasure3": strMeasure3,
        "strIngredient4": strIngredient4,
        "strMeasure4": strMeasure4,
        "strIngredient5": strIngredient5,
        "strMeasure5": strMeasure5,
        "strIngredient6": strIngredient6,
        "strMeasure6": strMeasure6,
        "strSource": strSource,
        "strImageSource": strImageSource,
        "strCreativeCommonsConfirmed": strCreativeCommonsConfirmed,
        "dateModified": dateModified,
      };
}
