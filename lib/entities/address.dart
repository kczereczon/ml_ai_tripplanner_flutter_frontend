class Address {
  final String street;
  final String number;
  final String postalCode;
  final String city;

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
