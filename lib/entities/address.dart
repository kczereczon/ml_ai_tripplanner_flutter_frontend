class Address {
  String street = "";
  String number = "";
  String postalCode = "";
  String city = "";

  Address(this.street, this.number, this.postalCode, this.city);

  String getAddressOnUi() {
    String addressString = "";

    if (street.isNotEmpty) {
      addressString += street;
      if (number.isNotEmpty) {
        addressString += " " + number + ", ";
      } else {
        addressString += ", ";
      }
    }
    if (postalCode.isNotEmpty) {
      addressString += postalCode + " ";
    }
    if (city.isNotEmpty) {
      addressString += city;
    }

    return addressString;
  }
}
