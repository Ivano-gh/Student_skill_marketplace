import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _selectedCategory = 'All';
  String _selectedCondition = 'Any';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for anything...',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.slidersHorizontal, color: Colors.white, size: 18),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Categories
            Text('Category', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                'All', 'Textbooks', 'Electronics', 'Dorm Essentials', 'Services', 'Clothing'
              ].map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = category);
                  },
                  selectedColor: theme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                  ),
                  backgroundColor: theme.colorScheme.surface,
                  side: BorderSide(
                    color: isSelected ? theme.primaryColor : theme.dividerColor.withValues(alpha: 0.2),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Price Range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price Range', style: theme.textTheme.titleMedium),
                Text(
                  'GH₵ ${_priceRange.start.round()} - GH₵ ${_priceRange.end.round()}',
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 5000,
              divisions: 50,
              activeColor: theme.primaryColor,
              inactiveColor: theme.primaryColor.withValues(alpha: 0.2),
              labels: RangeLabels(
                'GH₵ ${_priceRange.start.round()}',
                'GH₵ ${_priceRange.end.round()}',
              ),
              onChanged: (values) {
                setState(() => _priceRange = values);
              },
            ),
            const SizedBox(height: 32),

            // Condition
            Text('Condition', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                'Any', 'New', 'Like New', 'Used - Good', 'Used - Fair'
              ].map((condition) {
                final isSelected = _selectedCondition == condition;
                return ChoiceChip(
                  label: Text(condition),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCondition = condition);
                  },
                  selectedColor: theme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                  ),
                  backgroundColor: theme.colorScheme.surface,
                  side: BorderSide(
                    color: isSelected ? theme.primaryColor : theme.dividerColor.withValues(alpha: 0.2),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Apply filters action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filters Applied')),
                  );
                },
                child: const Text('Show 42 Results'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
