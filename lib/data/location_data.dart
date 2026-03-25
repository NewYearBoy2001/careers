class LocationData {
  static const Map<String, List<String>> stateDistricts = {
    'Kerala': [
      'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha',
      'Kottayam', 'Idukki', 'Ernakulam', 'Thrissur', 'Palakkad',
      'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasaragod',
    ],
    'Karnataka': [
      'Bengaluru Urban', 'Bengaluru Rural', 'Mysuru', 'Mangaluru',
      'Hubballi-Dharwad', 'Belagavi', 'Kalaburagi', 'Ballari',
      'Shivamogga', 'Tumakuru', 'Vijayapura', 'Bidar', 'Raichur',
      'Koppal', 'Gadag', 'Haveri', 'Uttara Kannada', 'Udupi',
      'Chikkamagaluru', 'Hassan', 'Kodagu', 'Mandya', 'Chamrajanagar',
      'Davanagere', 'Chitradurga', 'Yadgir', 'Ramanagara', 'Chikkaballapur',
      'Kolar', 'Bagalkot',
    ],
    'Tamil Nadu': [
      'Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem',
      'Tirunelveli', 'Tiruppur', 'Ranipet', 'Vellore', 'Erode',
      'Thoothukudi', 'Dindigul', 'Thanjavur', 'Kancheepuram', 'Chengalpattu',
      'Villupuram', 'Cuddalore', 'Nagapattinam', 'Tiruvarur', 'Pudukkottai',
      'Sivaganga', 'Virudhunagar', 'Ramanathapuram', 'Tenkasi', 'Nagercoil',
      'The Nilgiris', 'Namakkal', 'Karur', 'Perambalur', 'Ariyalur',
      'Kallakurichi', 'Tirupattur', 'Krishnagiri', 'Dharmapuri',
      'Tiruvannamalai',
    ],
  };

  static List<String> get states => stateDistricts.keys.toList();
  static List<String> districtsOf(String state) => stateDistricts[state] ?? [];
}