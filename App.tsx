import { StatusBar } from 'expo-status-bar';
import { Button, StyleSheet, Text, ToastAndroid, View } from 'react-native';
import * as DocumentPicker from 'expo-document-picker';

export default function App() {
  const onClick = async () => {
    try {
      const x = await DocumentPicker.getDocumentAsync({
        type: "application/vnd.android.package-archive"
      })
      console.log(x)
    } catch (err) {
      console.error(err)
    }
  }

  return (
    <View style={styles.container}>
      <Text>Open up App.tsx to start working on your app!</Text>
      <StatusBar style="auto" />
      <Button onPress={onClick} title='Click Me' />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
