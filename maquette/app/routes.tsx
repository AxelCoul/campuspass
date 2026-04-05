import { createBrowserRouter } from 'react-router';
import { Layout } from './layout';
import { Home } from './screens/home';
import { Explorer } from './screens/explorer';
import { Favoris } from './screens/favoris';
import { Merchants } from './screens/merchants';
import { MerchantDetail } from './screens/merchant-detail';

export const router = createBrowserRouter([
  {
    path: '/',
    Component: Layout,
    children: [
      { index: true, Component: Home },
      { path: 'explorer', Component: Explorer },
      { path: 'favoris', Component: Favoris },
      { path: 'merchants', Component: Merchants },
      { path: 'merchant/:id', Component: MerchantDetail },
    ],
  },
]);
