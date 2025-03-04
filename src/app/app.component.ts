import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: true,  // This makes it a standalone component
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'app';
}
