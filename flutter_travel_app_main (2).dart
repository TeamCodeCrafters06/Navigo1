// main.dart
// Simple Flutter travel app demo: Flights, Hotels, Packages, Booking & Expenses
// Run: flutter create my_app -> replace lib/main.dart with this file

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(TravelApp());
}

class TravelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Buddy',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomePage(),
    );
  }
}

// ----------------- Mock Models -----------------
class Flight {
  final String id;
  final String airline;
  final String from;
  final String to;
  final DateTime depart;
  final double price;
  Flight({required this.id, required this.airline, required this.from, required this.to, required this.depart, required this.price});
}

class Hotel {
  final String id;
  final String name;
  final String city;
  final double pricePerNight;
  final double rating;
  Hotel({required this.id, required this.name, required this.city, required this.pricePerNight, required this.rating});
}

class PackageItem {
  final String id;
  final String title;
  final String desc;
  final double price;
  PackageItem({required this.id, required this.title, required this.desc, required this.price});
}

class Booking {
  final String id;
  final String type; // flight/hotel/package
  final String title;
  final double amount;
  final DateTime date;
  Booking({required this.id, required this.type, required this.title, required this.amount, required this.date});
}

// ----------------- Sample Data -----------------
final List<Flight> sampleFlights = List.generate(5, (i) => Flight(
  id: 'F${i+1}',
  airline: ['Indigo', 'Air India', 'SpiceJet', 'Vistara', 'GoAir'][i%5],
  from: ['Trivandrum', 'Bengaluru', 'Chennai', 'Mumbai', 'Kolkata'][i%5],
  to: ['Chennai', 'Delhi', 'Goa', 'Hyderabad', 'Pune'][i%5],
  depart: DateTime.now().add(Duration(days: i+1, hours: 6)),
  price: 2000 + i*1500.0,
));

final List<Hotel> sampleHotels = List.generate(5, (i) => Hotel(
  id: 'H${i+1}',
  name: ['The Bay', 'Grand Inn', 'LakeView', 'CityLodge', 'ComfortStay'][i%5],
  city: ['Chennai','Bengaluru','Goa','Kochi','Pune'][i%5],
  pricePerNight: 1500 + i*800.0,
  rating: 3.5 + (i%3)*0.5,
));

final List<PackageItem> samplePackages = [
  PackageItem(id: 'P1', title: 'Chennai Weekend', desc: '2N/3D Chennai + city tour', price: 8000),
  PackageItem(id: 'P2', title: 'Goa Beach Break', desc: '3N/4D Goa with water sports', price: 12000),
  PackageItem(id: 'P3', title: 'Kerala Backwaters', desc: 'Houseboat + Ayurveda', price: 15000),
];

// ----------------- Global In-Memory Bookings -----------------
class InMemoryStore extends ChangeNotifier {
  final List<Booking> _bookings = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  void addBooking(Booking b) {
    _bookings.add(b);
    notifyListeners();
  }

  double get totalExpenses => _bookings.fold(0.0, (s, b) => s + b.amount);
}

// We'll instantiate a single store and pass it down.

// ----------------- Home Page with Bottom Navigation -----------------
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final store = InMemoryStore();

  final pages = <Widget>[]; // we'll initialize in initState to pass store

  @override
  void initState() {
    super.initState();
    pages.addAll([
      SearchPage(store: store),
      BookingsPage(store: store),
      ExpensesPage(store: store),
      ProfilePage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.paid), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      appBar: AppBar(title: Text('Travel Buddy')),
      floatingActionButton: _index==0 ? FloatingActionButton(
        onPressed: () => _showQuickPackageBooking(context),
        child: Icon(Icons.local_offer),
        tooltip: 'Quick Book Package',
      ) : null,
    );
  }

  void _showQuickPackageBooking(BuildContext context) {
    // Quick demo to book the first package
    final pkg = samplePackages[0];
    final booking = Booking(
      id: 'B${DateTime.now().millisecondsSinceEpoch}',
      type: 'package',
      title: pkg.title,
      amount: pkg.price,
      date: DateTime.now(),
    );
    store.addBooking(booking);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booked: ${pkg.title}')));
  }
}

// ----------------- Explore/Search Page -----------------
class SearchPage extends StatelessWidget {
  final InMemoryStore store;
  SearchPage({required this.store});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Explore'),
          bottom: TabBar(tabs: [Tab(text: 'Flights'), Tab(text: 'Hotels'), Tab(text: 'Packages')]),
        ),
        body: TabBarView(children: [
          FlightsTab(store: store),
          HotelsTab(store: store),
          PackagesTab(store: store),
        ]),
      ),
    );
  }
}

class FlightsTab extends StatelessWidget {
  final InMemoryStore store;
  FlightsTab({required this.store});
  final df = DateFormat('dd MMM, yyyy – hh:mm a');

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sampleFlights.length,
      itemBuilder: (c,i){
        final f = sampleFlights[i];
        return Card(
          child: ListTile(
            title: Text('${f.airline} — ${f.from} → ${f.to}'),
            subtitle: Text('${df.format(f.depart)}'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text('₹${f.price.toStringAsFixed(0)}'), SizedBox(height:4), ElevatedButton(onPressed: ()=>_bookFlight(context, f), child: Text('Book'))],
            ),
          ),
        );
      },
    );
  }

  void _bookFlight(BuildContext context, Flight f) {
    final booking = Booking(
      id: 'B${DateTime.now().millisecondsSinceEpoch}',
      type: 'flight',
      title: '${f.airline} ${f.from}→${f.to}',
      amount: f.price,
      date: DateTime.now(),
    );
    // access store via ancestor: find SearchPage then its store isn't available easily; workaround: use Navigator to return and add via callback
    // Simpler: use a global approach by locating HomePage's state via context.findAncestorStateOfType
    final homeState = context.findAncestorStateOfType<_HomePageState>();
    if (homeState != null) {
      homeState.store.addBooking(booking);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Flight booked: ${f.airline}')));
    }
  }
}

class HotelsTab extends StatelessWidget {
  final InMemoryStore store;
  HotelsTab({required this.store});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sampleHotels.length,
      itemBuilder: (c,i){
        final h = sampleHotels[i];
        return Card(
          child: ListTile(
            title: Text('${h.name} — ${h.city}'),
            subtitle: Text('₹${h.pricePerNight.toStringAsFixed(0)} / night — ${h.rating}★'),
            trailing: ElevatedButton(onPressed: ()=>_bookHotel(context, h), child: Text('Book')),
          ),
        );
      },
    );
  }

  void _bookHotel(BuildContext context, Hotel h) async {
    final nights = await showDialog<int>(context: context, builder: (ctx)=>_NightsDialog());
    if (nights!=null && nights>0){
      final amt = h.pricePerNight * nights;
      final booking = Booking(id: 'B${DateTime.now().millisecondsSinceEpoch}', type: 'hotel', title: '${h.name} (${nights}N)', amount: amt, date: DateTime.now());
      final homeState = context.findAncestorStateOfType<_HomePageState>();
      if (homeState!=null){
        homeState.store.addBooking(booking);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hotel booked: ${h.name} — ₹${amt.toStringAsFixed(0)}')));
      }
    }
  }
}

class PackagesTab extends StatelessWidget {
  final InMemoryStore store;
  PackagesTab({required this.store});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: samplePackages.length,
      itemBuilder: (c,i){
        final p = samplePackages[i];
        return Card(
          child: ListTile(
            title: Text(p.title),
            subtitle: Text(p.desc),
            trailing: Column(mainAxisSize: MainAxisSize.min, children: [Text('₹${p.price.toStringAsFixed(0)}'), SizedBox(height:4), ElevatedButton(onPressed: ()=>_bookPackage(context, p), child: Text('Book'))]),
          ),
        );
      },
    );
  }

  void _bookPackage(BuildContext context, PackageItem p) {
    final booking = Booking(id: 'B${DateTime.now().millisecondsSinceEpoch}', type: 'package', title: p.title, amount: p.price, date: DateTime.now());
    final homeState = context.findAncestorStateOfType<_HomePageState>();
    if (homeState!=null){
      homeState.store.addBooking(booking);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Package booked: ${p.title}')));
    }
  }
}

class _NightsDialog extends StatefulWidget {
  @override
  __NightsDialogState createState() => __NightsDialogState();
}
class __NightsDialogState extends State<_NightsDialog> {
  int nights = 1;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose nights'),
      content: Row(children: [IconButton(onPressed: ()=>setState(()=>nights=max(1, nights-1)), icon: Icon(Icons.remove)), Text('$nights'), IconButton(onPressed: ()=>setState(()=>nights+=1), icon: Icon(Icons.add))]),
      actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text('Cancel')), ElevatedButton(onPressed: ()=>Navigator.pop(context, nights), child: Text('Book'))],
    );
  }
}

int max(int a, int b) => a>b?a:b;

// ----------------- Bookings Page -----------------
class BookingsPage extends StatefulWidget {
  final InMemoryStore store;
  BookingsPage({required this.store});
  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  void initState(){
    super.initState();
    widget.store.addListener(_onChange);
  }
  @override
  void dispose(){
    widget.store.removeListener(_onChange);
    super.dispose();
  }
  void _onChange(){ setState((){}); }

  @override
  Widget build(BuildContext context) {
    final bookings = widget.store.bookings.reversed.toList();
    if (bookings.isEmpty) return Center(child: Text('No bookings yet.'));
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (c,i){
        final b = bookings[i];
        return Card(
          child: ListTile(
            title: Text('${b.title}'),
            subtitle: Text('${b.type.toUpperCase()} — ${DateFormat('dd MMM yyyy').format(b.date)}'),
            trailing: Text('₹${b.amount.toStringAsFixed(0)}'),
            onTap: ()=>_showBookingDetail(context, b),
          ),
        );
      },
    );
  }

  void _showBookingDetail(BuildContext context, Booking b){
    showDialog(context: context, builder: (ctx)=>AlertDialog(
      title: Text(b.title),
      content: Column(mainAxisSize: MainAxisSize.min, children: [Text('Type: ${b.type}'), Text('Amount: ₹${b.amount.toStringAsFixed(0)}'), Text('Date: ${DateFormat('dd MMM yyyy hh:mm a').format(b.date)}')]),
      actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text('Close'))],
    ));
  }
}

// ----------------- Expenses Page -----------------
class ExpensesPage extends StatefulWidget {
  final InMemoryStore store;
  ExpensesPage({required this.store});
  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  void initState(){
    super.initState();
    widget.store.addListener(_onChg);
  }
  void _onChg(){ setState((){}); }
  @override
  void dispose(){ widget.store.removeListener(_onChg); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final total = widget.store.totalExpenses;
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Total Expenses', style: TextStyle(fontSize:18, fontWeight: FontWeight.bold)),
        SizedBox(height:8),
        Text('₹${total.toStringAsFixed(0)}', style: TextStyle(fontSize:28, fontWeight: FontWeight.bold)),
        SizedBox(height:16),
        Expanded(child: widget.store.bookings.isEmpty ? Center(child: Text('No expenses recorded.')) : ListView(
          children: widget.store.bookings.map((b)=>ListTile(title: Text(b.title), subtitle: Text('${b.type}'), trailing: Text('₹${b.amount.toStringAsFixed(0)}'))).toList()
        ))
      ]),
    );
  }
}

// ----------------- Profile Page -----------------
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius:40, child: Icon(Icons.person, size:40)),
          SizedBox(height:12), Text('Traveler', style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
          SizedBox(height:6), Text('travelbuddy@example.com'),
          SizedBox(height:20), ElevatedButton(onPressed: ()=>_showAbout(context), child: Text('About App'))
        ]),
      ),
    );
  }
  void _showAbout(BuildContext context){
    showDialog(context: context, builder: (ctx)=>AlertDialog(title: Text('About'), content: Text('Demo travel app: explore flights, hotels, packages, book & track expenses.'), actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text('Close'))]));
  }
}

// ----------------- End of File -----------------
