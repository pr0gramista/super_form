import 'package:flutter/material.dart';
import 'package:super_form/super_form.dart';

import 'form.dart';
import 'model.dart';

class BurritoList extends StatefulWidget {
  final List<BurritoOrder> orders;
  final void Function(BurritoOrder oldOrder, BurritoOrder order) onSubmit;

  const BurritoList({
    Key? key,
    required this.orders,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _BurritoListState createState() => _BurritoListState();
}

class _BurritoListState extends State<BurritoList> {
  BurritoOrder? editingOrder;
  GlobalKey<SuperFormState> formKey = GlobalKey<SuperFormState>();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.orders.length,
      itemBuilder: (context, i) {
        final order = widget.orders[i];

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            child: InkWell(
              onTap: () {
                editingOrder = order;

                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: BurritoForm(
                        formKey: formKey,
                        isEditing: true,
                        initialValues: {
                          'count': order.count.toString(),
                          'filling': order.burrito.filling,
                          'sauce': order.burrito.sauce.toList(),
                          'extras': order.burrito.extras.toList(),
                        },
                        onSubmit: (order) {
                          widget.onSubmit(editingOrder!, order);
                          editingOrder = null;

                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      "${order.count}x",
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🌯 with ${order.burrito.filling}'),
                        Text("With ${order.burrito.sauce.join(', ')}"),
                        if (order.burrito.extras.isNotEmpty)
                          Text("Extras: ${order.burrito.extras.join(', ')}")
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
