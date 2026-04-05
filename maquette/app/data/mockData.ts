export interface Offer {
  id: string;
  title: string;
  subtitle: string;
  category: string;
  categoryIcon: string;
  originalPrice: number;
  finalPrice: number;
  location: string;
  rating: number;
  image: string;
  merchantId: string;
}

export interface Merchant {
  id: string;
  name: string;
  logo: string;
  category: string;
  categoryIcon: string;
  subcategory: string;
  location: string;
  distance: number;
  offersCount: number;
  address: string;
  hours: string;
  bannerImage: string;
  offers: string[]; // offer IDs
}

export const categories = [
  { id: 'all', label: 'Tout', icon: '🏪' },
  { id: 'restaurant', label: 'Restaurant', icon: '🍔' },
  { id: 'cafe', label: 'Café', icon: '☕' },
  { id: 'shopping', label: 'Shopping', icon: '🛍️' },
  { id: 'sport', label: 'Sport', icon: '⚽' },
  { id: 'culture', label: 'Culture', icon: '🎭' },
  { id: 'transport', label: 'Transport', icon: '🚌' },
];

export const mockOffers: Offer[] = [
  {
    id: '1',
    title: 'Burger House',
    subtitle: '-30% menu étudiant',
    category: 'RESTAURANT',
    categoryIcon: '🍔',
    originalPrice: 15000,
    finalPrice: 10500,
    location: 'Zogona',
    rating: 4.3,
    image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop',
    merchantId: '1',
  },
  {
    id: '2',
    title: 'Pizza King',
    subtitle: '-25% sur toutes les pizzas',
    category: 'RESTAURANT',
    categoryIcon: '🍕',
    originalPrice: 12000,
    finalPrice: 9000,
    location: 'Ouaga 2000',
    rating: 4.5,
    image: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&h=300&fit=crop',
    merchantId: '2',
  },
  {
    id: '3',
    title: 'Café des Arts',
    subtitle: '-20% boissons chaudes',
    category: 'CAFÉ',
    categoryIcon: '☕',
    originalPrice: 3000,
    finalPrice: 2400,
    location: 'Centre-ville',
    rating: 4.7,
    image: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=400&h=300&fit=crop',
    merchantId: '3',
  },
  {
    id: '4',
    title: 'Sport Zone',
    subtitle: '-15% équipements sportifs',
    category: 'SPORT',
    categoryIcon: '⚽',
    originalPrice: 25000,
    finalPrice: 21250,
    location: 'Gounghin',
    rating: 4.2,
    image: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=400&h=300&fit=crop',
    merchantId: '4',
  },
  {
    id: '5',
    title: 'Fresh Juice Bar',
    subtitle: '-30% jus naturels',
    category: 'CAFÉ',
    categoryIcon: '🥤',
    originalPrice: 2500,
    finalPrice: 1750,
    location: 'Zogona',
    rating: 4.6,
    image: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400&h=300&fit=crop',
    merchantId: '5',
  },
  {
    id: '6',
    title: 'Librairie Moderne',
    subtitle: '-20% fournitures scolaires',
    category: 'SHOPPING',
    categoryIcon: '📚',
    originalPrice: 8000,
    finalPrice: 6400,
    location: 'Centre-ville',
    rating: 4.4,
    image: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=300&fit=crop',
    merchantId: '6',
  },
];

export const mockMerchants: Merchant[] = [
  {
    id: '1',
    name: 'Burger House',
    logo: '🍔',
    category: 'Restaurant',
    categoryIcon: '🍔',
    subcategory: 'Fast-food',
    location: 'Zogona',
    distance: 0.8,
    offersCount: 1,
    address: 'Avenue Kwame N\'Krumah, Zogona',
    hours: 'Lun-Dim: 10h-22h',
    bannerImage: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800&h=400&fit=crop',
    offers: ['1'],
  },
  {
    id: '2',
    name: 'Pizza King',
    logo: '🍕',
    category: 'Restaurant',
    categoryIcon: '🍕',
    subcategory: 'Pizzeria',
    location: 'Ouaga 2000',
    distance: 1.2,
    offersCount: 1,
    address: 'Boulevard Charles de Gaulle, Ouaga 2000',
    hours: 'Lun-Dim: 11h-23h',
    bannerImage: 'https://images.unsplash.com/photo-1579751626657-72bc17010498?w=800&h=400&fit=crop',
    offers: ['2'],
  },
  {
    id: '3',
    name: 'Café des Arts',
    logo: '☕',
    category: 'Café',
    categoryIcon: '☕',
    subcategory: 'Salon de thé',
    location: 'Centre-ville',
    distance: 0.5,
    offersCount: 1,
    address: 'Rue de la Révolution, Centre-ville',
    hours: 'Lun-Sam: 7h-20h',
    bannerImage: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800&h=400&fit=crop',
    offers: ['3'],
  },
  {
    id: '4',
    name: 'Sport Zone',
    logo: '⚽',
    category: 'Sport',
    categoryIcon: '⚽',
    subcategory: 'Équipements sportifs',
    location: 'Gounghin',
    distance: 1.8,
    offersCount: 1,
    address: 'Avenue de la Nation, Gounghin',
    hours: 'Lun-Sam: 9h-19h',
    bannerImage: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=800&h=400&fit=crop',
    offers: ['4'],
  },
  {
    id: '5',
    name: 'Fresh Juice Bar',
    logo: '🥤',
    category: 'Café',
    categoryIcon: '🥤',
    subcategory: 'Bar à jus',
    location: 'Zogona',
    distance: 0.9,
    offersCount: 1,
    address: 'Carrefour Zogona',
    hours: 'Lun-Dim: 8h-21h',
    bannerImage: 'https://images.unsplash.com/photo-1622597467836-f3285f2131b8?w=800&h=400&fit=crop',
    offers: ['5'],
  },
  {
    id: '6',
    name: 'Librairie Moderne',
    logo: '📚',
    category: 'Shopping',
    categoryIcon: '📚',
    subcategory: 'Librairie',
    location: 'Centre-ville',
    distance: 0.6,
    offersCount: 1,
    address: 'Avenue Loudun, Centre-ville',
    hours: 'Lun-Sam: 8h-18h',
    bannerImage: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=800&h=400&fit=crop',
    offers: ['6'],
  },
];
